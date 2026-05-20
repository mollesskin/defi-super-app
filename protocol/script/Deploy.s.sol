// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/token/GovToken.sol";
import "../src/token/MockUSDC.sol";
import "../src/token/LPBadgeNFT.sol";
import "../src/amm/AMMFactory.sol";
import "../src/lending/LendingPool.sol";
import "../src/vault/YieldVault.sol";
import "../src/oracle/ChainlinkOracle.sol";
import "../src/governance/DeFiGovernor.sol";
import "../src/governance/Timelock.sol";
import "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        console.log("Deploying to Arbitrum Sepolia");
        console.log("Deployer:", deployer);
        console.log("========================================");

        // 1. Deploy Token Contracts
        console.log("[1/9] Deploying GovToken...");
        GovToken govToken = new GovToken();
        console.log("GovToken:", address(govToken));

        console.log("[2/9] Deploying MockUSDC...");
        MockUSDC usdc = new MockUSDC();
        console.log("MockUSDC:", address(usdc));

        console.log("[3/9] Deploying LPBadgeNFT...");
        LPBadgeNFT lpNFT = new LPBadgeNFT();
        console.log("LPBadgeNFT:", address(lpNFT));

        // 2. Deploy AMM
        console.log("[4/9] Deploying AMMFactory...");
        AMMFactory ammFactory = new AMMFactory();
        console.log("AMMFactory:", address(ammFactory));

        // 3. Deploy Lending Pool
        console.log("[5/9] Deploying LendingPool...");
        LendingPool lendingPool = new LendingPool();
        console.log("LendingPool:", address(lendingPool));

        // 4. Deploy Vault with USDC
        console.log("[6/9] Deploying YieldVault...");
        YieldVault vault = new YieldVault(ERC20(address(usdc)));
        console.log("YieldVault:", address(vault));

        // 5. Deploy Oracle
        console.log("[7/9] Deploying ChainlinkOracle...");
        ChainlinkOracle oracle = new ChainlinkOracle(address(0), 1 hours);
        console.log("ChainlinkOracle:", address(oracle));

        // 6. Deploy Timelock
        console.log("[8/9] Deploying DeFiTimelock...");
        uint256 timelockDelay = 2 days;
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](0);
        DeFiTimelock timelock = new DeFiTimelock(timelockDelay, proposers, executors, deployer);
        console.log("DeFiTimelock:", address(timelock));

        // 7. Deploy Governor
        console.log("[9/9] Deploying DeFiGovernor...");
        DeFiGovernor governor = new DeFiGovernor(
            IVotes(address(govToken)),
            TimelockController(payable(address(timelock)))
        );
        console.log("DeFiGovernor:", address(governor));

        // 8. Save addresses to file
        console.log("Saving addresses...");
        string memory json = createJson(
            address(govToken),
            address(usdc),
            address(lpNFT),
            address(ammFactory),
            address(lendingPool),
            address(vault),
            address(oracle),
            address(timelock),
            address(governor)
        );
        
        vm.writeFile("../frontend/src/config/deployed_addresses.json", json);
        console.log("Deployment Complete!");
        console.log("========================================");

        vm.stopBroadcast();
    }

    function createJson(
        address govToken,
        address usdc,
        address lpNFT,
        address ammFactory,
        address lendingPool,
        address vault,
        address oracle,
        address timelock,
        address governor
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '{',
            '"network":"arbitrum-sepolia",',
            '"chainId":421614,',
            '"govToken":"', addressToString(govToken), '",',
            '"usdc":"', addressToString(usdc), '",',
            '"lpNFT":"', addressToString(lpNFT), '",',
            '"ammFactory":"', addressToString(ammFactory), '",',
            '"lendingPool":"', addressToString(lendingPool), '",',
            '"vault":"', addressToString(vault), '",',
            '"oracle":"', addressToString(oracle), '",',
            '"timelock":"', addressToString(timelock), '",',
            '"governor":"', addressToString(governor), '"',
            '}'
        ));
    }

    function addressToString(address _addr) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(_addr)) / (2**(8*(19-i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);
        }
        return string(abi.encodePacked("0x", s));
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}
