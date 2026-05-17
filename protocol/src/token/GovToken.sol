// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "openzeppelin-contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "openzeppelin-contracts/token/ERC20/extensions/ERC20Votes.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

contract GovToken is ERC20, ERC20Permit, ERC20Votes, Ownable {
    constructor()
        ERC20("DeFi SuperApp Governance", "DSG")
        ERC20Permit("DeFi SuperApp Governance")
        Ownable(msg.sender)
    {
        _mint(msg.sender, 1_000_000e18);
    }

    function _update(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._update(from, to, amount);
    }

    function nonces(address owner)
        public
        view
        override(ERC20Permit)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}