// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract ChainlinkOracle {
    AggregatorV3Interface public immutable feed;
    uint256 public immutable staleAfter; // seconds

    constructor(address _feed, uint256 _staleAfter) {
        feed = AggregatorV3Interface(_feed);
        staleAfter = _staleAfter;
    }

    function latestPrice() external view returns (int256) {
        (, int256 price,, uint256 updatedAt,) = feed.latestRoundData();
        require(price > 0, "Invalid price");
        require(block.timestamp - updatedAt <= staleAfter, "Stale price");
        return price;
    }
}