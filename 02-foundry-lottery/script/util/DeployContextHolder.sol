// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Constants} from "../library/Constants.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mock/LinkToken.sol";
import {Script, console2} from "forge-std/Script.sol";

error RaffleDeployHelper__ChainNotSupported();

contract DeployContextHolder is Script {

    struct DeployContext {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinatorAddress;
        bytes32 keyHash;
        address linkTokenAddress;
        address account;
        uint256 subId;
    }

    DeployContext private s_activeContext;

    constructor() {
        initializeConfigByChainId();
    }

    function getDeployContext() public view returns (DeployContext memory) {
        if (s_activeContext.account == address(0)) {
            revert RaffleDeployHelper__ChainNotSupported();
        }
        return s_activeContext;
    }

    function getSubscriptionId() external view returns (uint256) {
        return s_activeContext.subId;
    }

    function setSubscriptionId(uint256 subId) external {
        s_activeContext.subId = subId;
    }

    function getVrfCoordinatorAddress() external view returns (address) {
        return s_activeContext.vrfCoordinatorAddress;
    }

    function initializeConfigByChainId() private {
        if (block.chainid == Constants.ETH_SEPOLIA_CHAIN_ID) {
            initializeEthSepoliaContext();
        } else if (block.chainid == Constants.ETH_MAIN_NET_CHAIN_ID) {
            initializeEthMainNetContext();
        } else if (block.chainid == Constants.ANVIL_CHAIN_ID) {
            initializeAnvilContext();
        }
    }

    function initializeEthSepoliaContext() private {
        console2.log("Create ethereum sepolia deploy context");
        s_activeContext = DeployContext({
            entranceFee: Constants.DEFAULT_ENTRANCE_FEE,
            interval: Constants.DEFAULT_INTERVAL,
            vrfCoordinatorAddress: Constants.ETH_SEPOLIA_VRF_COORDINATOR_ADDRESS,
            keyHash: Constants.ETH_SEPOLIA_GAS_LANE,
            linkTokenAddress: Constants.ETH_SEPOLIA_LINK_TOKEN_ADDRESS,
            subId: Constants.ETH_SEPOLIA_SUBSCRIPTION_ID,
            account: Constants.ETH_SEPOLIA_DEFAULT_ACCOUNT
        });
    }

    function initializeEthMainNetContext() private {
        console2.log("Create ethereum mainnet deploy context");
        s_activeContext = DeployContext({
            entranceFee: Constants.DEFAULT_ENTRANCE_FEE,
            interval: Constants.DEFAULT_INTERVAL,
            vrfCoordinatorAddress: Constants.ETH_MAIN_NET_VRF_COORDINATOR_ADDRESS,
            keyHash: Constants.ETH_MAIN_NET_GAS_LANE,
            linkTokenAddress: Constants.ETH_MAIN_NET_LINK_TOKEN_ADDRESS,
            subId: Constants.ETH_MAIN_NET_SUBSCRIPTION_ID,
            account: Constants.ETH_MAIN_NET_DEFAULT_ACCOUNT
        });
    }

    function initializeAnvilContext() private {
        console2.log("Create anvil context");
        vm.startBroadcast();
        LinkToken linkToken = deployLinkTokenMock();
        VRFCoordinatorV2_5Mock mockVrfCoordinator = deployVrfCoordinatorMock();
        vm.stopBroadcast();
        s_activeContext = DeployContext({
            entranceFee: Constants.DEFAULT_ENTRANCE_FEE,
            interval: Constants.DEFAULT_INTERVAL,
            vrfCoordinatorAddress: address(mockVrfCoordinator),
            keyHash: 0x0, // 没有也没事
            linkTokenAddress: address(linkToken),
            account: Constants.FOUNDRY_DEFAULT_SENDER,
            subId: 0 // 部署 Raffle 的时候会自动创建
        });
    }

    function deployVrfCoordinatorMock() private returns (VRFCoordinatorV2_5Mock) {
        return new VRFCoordinatorV2_5Mock(
            Constants.MOCK_BASE_FEE,
            Constants.MOCK_GAS_PRICE_LINK,
            Constants.MOCK_WEI_PER_UINT_LINK);
    }

    function deployLinkTokenMock() private returns (LinkToken) {
        return new LinkToken();
    }
}