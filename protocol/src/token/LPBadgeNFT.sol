// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "openzeppelin-contracts/token/ERC721/ERC721.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

contract LPBadgeNFT is ERC721, Ownable {
    uint256 public nextId;

    constructor() ERC721("LP Badge", "LPB") {}

    function mint(address to) external onlyOwner returns (uint256) {
        uint256 id = ++nextId;
        _safeMint(to, id);
        return id;
    }
}