// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/amm/AMMPair.sol";
import "../src/token/MockUSDC.sol";

contract AMMPairTest is Test {
    MockUSDC tokenA;
    MockUSDC tokenB;
    AMMPair pair;
    address lp = address(0x1);
    address trader = address(0x2);

    function setUp() public {
        tokenA = new MockUSDC();
        tokenB = new MockUSDC();
        pair = new AMMPair(address(tokenA), address(tokenB));

        tokenA.mint(lp, 1_000e18);
        tokenB.mint(lp, 1_000e18);

        vm.startPrank(lp);
        tokenA.approve(address(pair), type(uint256).max);
        tokenB.approve(address(pair), type(uint256).max);
        tokenA.transfer(address(pair), 1_000e18);
        tokenB.transfer(address(pair), 1_000e18);
        pair.mint(lp);
        vm.stopPrank();

        tokenA.mint(trader, 100e18);
        vm.startPrank(trader);
        tokenA.approve(address(pair), type(uint256).max);
        vm.stopPrank();
    }

    function testSwap() public {
        vm.startPrank(trader);
        uint256 balanceBefore = tokenB.balanceOf(trader);
        pair.swap(address(tokenA), 10e18, 0, trader);
        uint256 balanceAfter = tokenB.balanceOf(trader);
        assertGt(balanceAfter, balanceBefore);
        vm.stopPrank();
    }

    // Fuzz example
    function testFuzz_swapAmount(uint256 amountIn) public {
        vm.assume(amountIn > 0 && amountIn < 100e18);

        vm.startPrank(trader);
        pair.swap(address(tokenA), amountIn, 0, trader);
        vm.stopPrank();
    }
}