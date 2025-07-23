// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {DeployConstants} from "./DeployConstants.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mock/LinkToken.sol";
import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {BroadcastScript} from "./BroadcastScript.sol";

    error RaffleDeployHelper__ChainNotSupported();

contract DeployHelper is DeployConstants, BroadcastScript {

    struct DeployConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinatorAddress;
        uint256 subscriptionId;
        bytes32 keyHash;
        address linkTokenAddress;
        address account;
    }

    mapping(uint256 chainId => DeployConfig config) private configMap;

    constructor() {
        initializeConfigByChainId();
    }

    function initializeConfigByChainId() private {
        configMap[ETH_SEPOLIA_CHAIN_ID] = createEthSepoliaConfig();
        configMap[ETH_MAIN_NET_CHAIN_ID] = createEthMainNetConfig();
        configMap[ANVIL_CHAIN_ID] = createAnvilConfig();
    }

    function createEthSepoliaConfig() private returns (DeployConfig memory) {
        uint256 subId = createSubscription(ETH_SEPOLIA_VRF_COORDINATOR_ADDRESS);
        IVRFCoordinatorV2Plus vrfCoordinator = IVRFCoordinatorV2Plus(ETH_MAIN_NET_VRF_COORDINATOR_ADDRESS);
        LinkToken linkToken = LinkToken(ETH_MAIN_NET_LINK_TOKEN_ADDRESS);
        linkToken.transferAndCall(address(vrfCoordinator), DEFAULT_FUND_AMOUNT, abi.encode(subId));
        return DeployConfig({
            entranceFee: DEFAULT_ENTRANCE_FEE,
            interval: DEFAULT_INTERVAL,
            vrfCoordinatorAddress: ETH_SEPOLIA_VRF_COORDINATOR_ADDRESS,
            subscriptionId: subId,
            keyHash: ETH_SEPOLIA_GAS_LANE,
            linkTokenAddress: ETH_SEPOLIA_LINK_TOKEN_ADDRESS,
            account: 0x37CA3984F65bEB9400669c94faeEFaf1FC649964
        });
    }

    function createEthMainNetConfig() private returns (DeployConfig memory) {
        uint256 subId = createSubscription(ETH_MAIN_NET_VRF_COORDINATOR_ADDRESS);
        IVRFCoordinatorV2Plus vrfCoordinator = IVRFCoordinatorV2Plus(ETH_MAIN_NET_VRF_COORDINATOR_ADDRESS);
        LinkToken linkToken = LinkToken(ETH_MAIN_NET_LINK_TOKEN_ADDRESS);
        linkToken.transferAndCall(address(vrfCoordinator), DEFAULT_FUND_AMOUNT, abi.encode(subId));
        return DeployConfig({
            entranceFee: DEFAULT_ENTRANCE_FEE,
            interval: DEFAULT_INTERVAL,
            vrfCoordinatorAddress: ETH_MAIN_NET_VRF_COORDINATOR_ADDRESS,
            subscriptionId: subId,
            keyHash: ETH_MAIN_NET_GAS_LANE,
            linkTokenAddress: ETH_MAIN_NET_LINK_TOKEN_ADDRESS,
            account: 0x37CA3984F65bEB9400669c94faeEFaf1FC649964
        });
    }

    function createAnvilConfig() private broadcast returns (DeployConfig memory) {
        LinkToken linkToken = deployLinkTokenMock();
        VRFCoordinatorV2_5Mock mockVrfCoordinator = deployVrfCoordinatorMock();
        uint256 subId = mockVrfCoordinator.createSubscription();
        mockVrfCoordinator.fundSubscription(subId, DEFAULT_FUND_AMOUNT);
        return DeployConfig({
            entranceFee: DEFAULT_ENTRANCE_FEE,
            interval: DEFAULT_INTERVAL,
            vrfCoordinatorAddress: address(mockVrfCoordinator),
            subscriptionId: subId,
            keyHash: 0x0, // 没有也没事
            linkTokenAddress: address(linkToken),
            account: FOUNDRY_DEFAULT_SENDER
        });
    }

    function createSubscription(address vrfCoordinatorAddress) private broadcast returns (uint256) {
        IVRFCoordinatorV2Plus vrfCoordinator = IVRFCoordinatorV2Plus(vrfCoordinatorAddress);
        return vrfCoordinator.createSubscription();
    }

    function deployVrfCoordinatorMock() private broadcast returns (VRFCoordinatorV2_5Mock) {
        return new VRFCoordinatorV2_5Mock(
            MOCK_BASE_FEE, MOCK_GAS_PRICE_LINK, MOCK_WEI_PER_UINT_LINK);
    }

    function deployLinkTokenMock() private broadcast returns (LinkToken) {
        return new LinkToken();
    }

    function getDeployConfig(uint256 chainId) public view returns (DeployConfig memory) {
        DeployConfig memory config = configMap[chainId];
        if (config.vrfCoordinatorAddress == address(0)) {
            revert RaffleDeployHelper__ChainNotSupported();
        }
        return config;
    }
}