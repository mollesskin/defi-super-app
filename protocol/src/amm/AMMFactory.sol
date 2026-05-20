// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AMMPair} from "./AMMPair.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

contract AMMFactory is Ownable {
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    constructor() {}

    function createPair(address tokenA, address tokenB) external onlyOwner returns (address pair) {
        require(tokenA != tokenB, "IDENTICAL_ADDRESSES");
        (address token0, address token1) =
            tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(getPair[token0][token1] == address(0), "PAIR_EXISTS");

        pair = address(new AMMPair(token0, token1)); // CREATE
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function createPairDeterministic(
        address tokenA,
        address tokenB,
        bytes32 salt
    ) external onlyOwner returns (address pair) {
        require(tokenA != tokenB, "IDENTICAL_ADDRESSES");
        (address token0, address token1) =
            tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(getPair[token0][token1] == address(0), "PAIR_EXISTS");

        bytes memory bytecode = abi.encodePacked(
            type(AMMPair).creationCode,
            abi.encode(token0, token1)
        );

        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
            if iszero(pair) {
                revert(0, 0)
            }
        }

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }
}