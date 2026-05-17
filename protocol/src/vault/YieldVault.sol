// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC4626} from "openzeppelin-contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";
import {Pausable} from "openzeppelin-contracts/utils/Pausable.sol";
import {AccessControl} from "openzeppelin-contracts/access/AccessControl.sol";

contract YieldVault is ERC4626, Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    constructor(ERC20 asset_)
        ERC20(string(abi.encodePacked("Vault ", asset_.name())), string(abi.encodePacked("v", asset_.symbol())))
        ERC4626(asset_)
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _deposit(address caller, address receiver, uint256 assets, uint256 shares)
        internal
        override
        whenNotPaused
    {
        super._deposit(caller, receiver, assets, shares);
    }

    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal override whenNotPaused {
        super._withdraw(caller, receiver, owner, assets, shares);
    }
}