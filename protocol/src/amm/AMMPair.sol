// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/utils/ReentrancyGuard.sol";
import {Math} from "openzeppelin-contracts/utils/math/Math.sol";

contract AMMPair is ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public immutable token0;
    address public immutable token1;

    uint112 public reserve0;
    uint112 public reserve1;

    uint256 public constant FEE_NUM = 3;    // 0.3%
    uint256 public constant FEE_DEN = 1000;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1, uint256 liquidity);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        address indexed tokenIn,
        uint256 amountIn,
        address indexed tokenOut,
        uint256 amountOut,
        address to
    );

    constructor(address _token0, address _token1)
        ERC20("AMM LP", "AMM-LP")
    {
        require(_token0 != _token1, "Identical tokens");
        token0 = _token0;
        token1 = _token1;
    }

    function _update(uint112 _reserve0, uint112 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function getReserves() public view returns (uint112, uint112) {
        return (reserve0, reserve1);
    }

    function mint(address to) external nonReentrant returns (uint256 liquidity) {
        (uint112 _reserve0, uint112 _reserve1) = getReserves();
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));

        uint256 amount0 = balance0 - _reserve0;
        uint256 amount1 = balance1 - _reserve1;

        uint256 _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount1);
        } else {
            liquidity = Math.min(
                (amount0 * _totalSupply) / _reserve0,
                (amount1 * _totalSupply) / _reserve1
            );
        }
        require(liquidity > 0, "INSUFFICIENT_LIQUIDITY_MINTED");

        _mint(to, liquidity);
        _update(uint112(balance0), uint112(balance1));

        emit Mint(msg.sender, amount0, amount1, liquidity);
    }

    function burn(address to) external nonReentrant returns (uint256 amount0, uint256 amount1) {
        (uint112 _reserve0, uint112 _reserve1) = getReserves();
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));

        uint256 liquidity = balanceOf(address(this));
        uint256 _totalSupply = totalSupply();

        amount0 = (liquidity * balance0) / _totalSupply;
        amount1 = (liquidity * balance1) / _totalSupply;

        require(amount0 > 0 && amount1 > 0, "INSUFFICIENT_LIQUIDITY_BURNED");

        _burn(address(this), liquidity);

        IERC20(token0).safeTransfer(to, amount0);
        IERC20(token1).safeTransfer(to, amount1);

        balance0 = IERC20(token0).balanceOf(address(this));
        balance1 = IERC20(token1).balanceOf(address(this));

        _update(uint112(balance0), uint112(balance1));
        emit Burn(msg.sender, amount0, amount1, to);
    }

    function swap(
        address tokenIn,
        uint256 amountIn,
        uint256 minAmountOut,
        address to
    ) external nonReentrant returns (uint256 amountOut) {
        require(amountIn > 0, "INSUFFICIENT_INPUT_AMOUNT");
        require(tokenIn == token0 || tokenIn == token1, "INVALID_TOKEN");

        (uint112 _reserve0, uint112 _reserve1) = getReserves();

        bool isZero = tokenIn == token0;
        (uint112 reserveIn, uint112 reserveOut) = isZero
            ? (_reserve0, _reserve1)
            : (_reserve1, _reserve0);

        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);

        uint256 amountInWithFee = amountIn * (FEE_DEN - FEE_NUM) / FEE_DEN;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn + amountInWithFee;
        amountOut = numerator / denominator;

        require(amountOut >= minAmountOut, "SLIPPAGE");

        address tokenOut = isZero ? token1 : token0;
        IERC20(tokenOut).safeTransfer(to, amountOut);

        uint256 newBalanceIn = IERC20(isZero ? token0 : token1).balanceOf(address(this));
        uint256 newBalanceOut = IERC20(isZero ? token1 : token0).balanceOf(address(this));

        if (isZero) {
            _update(uint112(newBalanceIn), uint112(newBalanceOut));
        } else {
            _update(uint112(newBalanceOut), uint112(newBalanceIn));
        }

        emit Swap(msg.sender, tokenIn, amountIn, tokenOut, amountOut, to);
    }
}