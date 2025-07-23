// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol"; 
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";
import {ZkSyncChainChecker} from "../lib/foundry-devops/src/ZkSyncChainChecker.sol";

error DeployHelper__ChainNotSupported();

contract NetworkConfigHelper is Script, ZkSyncChainChecker {

    uint256 private constant ETHEREUM_SEPOLIA_CHAIN_ID = 11155111;

    uint256 private constant ETHEREUM_MAINNET_CHAIN_ID = 1;

    uint256 private constant LOCAL_ANVIL_CHAIN_ID = 31337;

    uint8 private constant DEFULAT_DECIMALS = 8;

    int256 private constant DEFAULT_ETH_PRICE = 2e11;

    NetworkConfig private activeNetworkConfig;

    struct NetworkConfig {
        address priceFeedAddress;
    }

    constructor() {
        if (block.chainid == ZKSYNC_SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getZKsyncSepoliaConfig();
        } else if (block.chainid == ZKSYNC_MAINNET_CHAIN_ID) {
            activeNetworkConfig = getZKsyncMainnetConfig();
        } else if (block.chainid == ETHEREUM_SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getEthSepoliaConfig();
        } else if (block.chainid == ETHEREUM_MAINNET_CHAIN_ID) {
            activeNetworkConfig = getEthMainnetConfig();
        } else if (block.chainid == LOCAL_ANVIL_CHAIN_ID) {
            activeNetworkConfig = getOrCreateAnvilConfig();
        } else {
            revert DeployHelper__ChainNotSupported();
        }
    }

    function getEthMainnetConfig() private pure returns (NetworkConfig memory) {
        return NetworkConfig({ priceFeedAddress: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 });
    }

    function getZKsyncSepoliaConfig() private pure returns (NetworkConfig memory) {
        return NetworkConfig({ priceFeedAddress: 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF });
    }

    function getZKsyncMainnetConfig() private pure returns (NetworkConfig memory) {
        return NetworkConfig({ priceFeedAddress: 0x6D41d1dc818112880b40e26BD6FD347E41008eDA });
    }

    function getEthSepoliaConfig() private pure returns (NetworkConfig memory) {
        return NetworkConfig({ priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306 });
    }

    function getOrCreateAnvilConfig() private returns (NetworkConfig memory) {
        // address 类型默认值是 address(0)
        if (activeNetworkConfig.priceFeedAddress != address(0)) {
            return activeNetworkConfig;
        }
        return NetworkConfig({ priceFeedAddress: address(deployMockPriceFeed()) });
    }

    function deployMockPriceFeed() private returns (AggregatorV3Interface) {
        vm.startBroadcast();
        AggregatorV3Interface mockPriceFeed = new MockV3Aggregator(DEFULAT_DECIMALS, DEFAULT_ETH_PRICE);
        vm.stopBroadcast();
        return mockPriceFeed;
    }

    function getActiveNetworkConfig() external view returns (NetworkConfig memory) {
        return activeNetworkConfig;
    }
}