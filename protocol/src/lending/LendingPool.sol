// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import {Initializable} from "openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlUpgradeable} from "openzeppelin-contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "openzeppelin-contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

interface IPriceOracle {
    function latestPrice() external view returns (int256);
}

contract LendingPool is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20 for IERC20;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    IERC20 public collateralToken;
    IERC20 public debtToken;
    IPriceOracle public priceOracle;

    // LTV and liquidation parameters (scaled by 1e4, e.g., 7500 = 75%)
    uint256 public ltvBps;
    uint256 public liquidationThresholdBps;
    uint256 public liquidationBonusBps;

    struct Position {
        uint256 collateral;
        uint256 debt;
    }

    mapping(address => Position) public positions;

    event DepositCollateral(address indexed user, uint256 amount);
    event WithdrawCollateral(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);
    event Liquidate(address indexed liquidator, address indexed user, uint256 repaid, uint256 seized);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _collateral,
        address _debt,
        address _oracle,
        uint256 _ltvBps,
        uint256 _liqThresholdBps,
        uint256 _liqBonusBps,
        address admin
    ) external initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);

        collateralToken = IERC20(_collateral);
        debtToken = IERC20(_debt);
        priceOracle = IPriceOracle(_oracle);
        ltvBps = _ltvBps;
        liquidationThresholdBps = _liqThresholdBps;
        liquidationBonusBps = _liqBonusBps;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(ADMIN_ROLE) {}

    // --- helpers ---

    function _collateralValueInDebt(uint256 collateralAmount) internal view returns (uint256) {
        int256 price = priceOracle.latestPrice(); // e.g., collateral / debt price * 1e8
        require(price > 0, "Price <= 0");
        // assume price has 8 decimals; collateral has 18; debt has 18
        return (collateralAmount * uint256(price)) / 1e8;
    }

    function healthFactor(address user) public view returns (uint256) {
        Position memory p = positions[user];
        if (p.debt == 0) return type(uint256).max;
        uint256 collValue = _collateralValueInDebt(p.collateral);
        // HF = (collValue * liqThreshold) / debt
        return (collValue * liquidationThresholdBps) / (p.debt * 1e4);
    }

    // --- actions ---

    function depositCollateral(uint256 amount) external nonReentrant {
        require(amount > 0, "zero");
        IERC20(collateralToken).safeTransferFrom(msg.sender, address(this), amount);
        positions[msg.sender].collateral += amount;
        emit DepositCollateral(msg.sender, amount);
    }

    function withdrawCollateral(uint256 amount) external nonReentrant {
        require(amount > 0, "zero");
        Position storage p = positions[msg.sender];
        require(p.collateral >= amount, "insufficient collateral");

        p.collateral -= amount;
        require(_isHealthy(msg.sender), "would go unhealthy");

        IERC20(collateralToken).safeTransfer(msg.sender, amount);
        emit WithdrawCollateral(msg.sender, amount);
    }

    function _isHealthy(address user) internal view returns (bool) {
        uint256 hf = healthFactor(user);
        return hf >= 1e18; // HF >= 1
    }

    function maxBorrowable(address user) public view returns (uint256) {
        Position memory p = positions[user];
        uint256 collValue = _collateralValueInDebt(p.collateral);
        uint256 maxDebt = (collValue * ltvBps) / 1e4;
        if (p.debt >= maxDebt) return 0;
        return maxDebt - p.debt;
    }

    function borrow(uint256 amount) external nonReentrant {
        require(amount > 0, "zero");
        uint256 available = maxBorrowable(msg.sender);
        require(amount <= available, "exceeds max borrow");
        positions[msg.sender].debt += amount;
        require(_isHealthy(msg.sender), "unhealthy");
        IERC20(debtToken).safeTransfer(msg.sender, amount);
        emit Borrow(msg.sender, amount);
    }

    function repay(uint256 amount) external nonReentrant {
        require(amount > 0, "zero");
        Position storage p = positions[msg.sender];
        require(p.debt > 0, "no debt");
        if (amount > p.debt) amount = p.debt;

        IERC20(debtToken).safeTransferFrom(msg.sender, address(this), amount);
        p.debt -= amount;
        emit Repay(msg.sender, amount);
    }

    function liquidate(address user, uint256 repayAmount) external nonReentrant {
        require(repayAmount > 0, "zero");
        require(healthFactor(user) < 1e18, "healthy");

        Position storage p = positions[user];
        require(p.debt > 0, "no debt");

        if (repayAmount > p.debt) repayAmount = p.debt;

        // liquidator pays debtToken to pool
        IERC20(debtToken).safeTransferFrom(msg.sender, address(this), repayAmount);
        p.debt -= repayAmount;

        uint256 collValue = _collateralValueInDebt(p.collateral);
        uint256 seizeValue = (repayAmount * (1e4 + liquidationBonusBps)) / 1e4;
        if (seizeValue > collValue) seizeValue = collValue;

        uint256 seizeAmount = (seizeValue * p.collateral) / collValue;

        p.collateral -= seizeAmount;
        IERC20(collateralToken).safeTransfer(msg.sender, seizeAmount);
        emit Liquidate(msg.sender, user, repayAmount, seizeAmount);
    }
}