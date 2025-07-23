// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {Script, console2} from "forge-std/Script.sol";
import {DeployHelper} from "./DeployHelper.sol";
import {BroadcastScript} from "./BroadcastScript.sol";
import {DeployHelperFactory} from "./DeployHelperFactory.sol";
import {DeployConstants} from "./DeployConstants.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mock/LinkToken.sol";

contract VrfSubscriptionManager is BroadcastScript, DeployConstants {

    function getOrCreateSubscription(uint256 chainId) public returns (uint256, uint256) {
        return createNewSubscriptionIfNotExist(chainId);
    }

    function getActiveSubscription(uint256 chainId) public returns (uint256) {
        (uint256 preSubId, uint256 newSubId) = createNewSubscriptionIfNotExist(chainId);
        return (preSubId != 0 && newSubId != 0) ? newSubId : preSubId != 0 ? preSubId : newSubId;
    }

    function createNewSubscriptionIfNotExist(uint256 chainId) private returns (uint256, uint256) {

        DeployHelper.DeployConfig memory config = getDeployConfig(chainId);
        IVRFCoordinatorV2Plus vrfCoordinator = IVRFCoordinatorV2Plus(config.vrfCoordinatorAddress);
        vm.startBroadcast();
        if (config.subscriptionId == 0) {
            console2.log("Vrf subscription id is not specified in deploy config, create new subscription ...");
            config.subscriptionId = createSubscription(vrfCoordinator);
            console2.log("Subscription id: ", config.subscriptionId);
            return (config.subscriptionId, 0);
        }
        (, , , address owner, ) = vrfCoordinator.getSubscription(config.subscriptionId);
        if (owner != msg.sender) {
            console2.log("The owner of the current subscription is ", owner);
            console2.log("The sender of the transaction is  ", msg.sender);
            console2.log("Create new subscription for current transaction sender, and remove the consumer from the previous subscription");
            uint256 preSubscriptionId = config.subscriptionId;
            uint256 newSubscriptionId = createSubscription(vrfCoordinator);
            config.subscriptionId = newSubscriptionId;
            console2.log("new subscription id: ", newSubscriptionId);
            return (newSubscriptionId, preSubscriptionId);
        }
        console2.log("The sender of the transaction is ", msg.sender);
        console2.log("Found existing subscription: ", config.subscriptionId);
        vm.stopBroadcast();
        return (0, config.subscriptionId);
    }

    function createSubscription(IVRFCoordinatorV2Plus vrfCoordinator) private broadcast returns (uint256) {
        return vrfCoordinator.createSubscription();
    }

    function addConsumer(address consumerAddress, uint256 chainId) external {
        // 拿到 deployConfig 中的 vrfCoordinator
        IVRFCoordinatorV2Plus vrfCoordinator = getVrfCoordinatorFromDeployConfig(chainId);
        // 拿到 vrf subscription id
        (uint256 newSubId, uint256 preSubId) = getOrCreateSubscription(chainId);
        if (newSubId != 0 && preSubId != 0) {
            // 如果创建了新的 Subscription，并且之前已经创建过 Subscription，要将当前的 Consumer
            // 从之前的 Subscription 中移除，一个 Consumer 只能存在于一个 Subscription 中
            (, , , , address[] memory consumers) = vrfCoordinator.getSubscription(preSubId);
            for (uint256 i = 0; i < consumers.length; i++) {
                if (consumers[i] == consumerAddress) {
                    vrfCoordinator.removeConsumer(preSubId, consumerAddress);
                }
            }
            addConsumer(vrfCoordinator, newSubId, consumerAddress);
        } else {
            uint256 subId = newSubId == 0 ? preSubId : newSubId;
            addConsumer(vrfCoordinator, subId, consumerAddress);
        }
    }

    function addConsumer(IVRFCoordinatorV2Plus vrfCoordinator, uint256 subId, address consumerAddress) public broadcast {
        vrfCoordinator.addConsumer(subId, consumerAddress);
    }

    function fundSubscription(uint256 chainId) external broadcast {
        uint256 subId = getActiveSubscription(chainId);
        IVRFCoordinatorV2Plus vrfCoordinator = getVrfCoordinatorFromDeployConfig(chainId);
        if (block.chainid == ANVIL_CHAIN_ID) {
            VRFCoordinatorV2_5Mock vrfCoordinatorMock = VRFCoordinatorV2_5Mock(address(vrfCoordinator));
            vrfCoordinatorMock.fundSubscription(subId, DEFAULT_FUND_AMOUNT);
        } else {
            LinkToken linkToken = LinkToken(ETH_MAIN_NET_LINK_TOKEN_ADDRESS);
            linkToken.transferAndCall(address(vrfCoordinator), DEFAULT_FUND_AMOUNT, abi.encode(subId));
        }
    }

    function getVrfCoordinatorFromDeployConfig(uint256 chainId) private returns (IVRFCoordinatorV2Plus) {
        DeployHelper.DeployConfig memory config = getDeployConfig(chainId);
        return IVRFCoordinatorV2Plus(config.vrfCoordinatorAddress);
    }

    function getDeployConfig(uint256 chainId) private returns (DeployHelper.DeployConfig memory) {
        DeployHelperFactory deployHelperFactory = new DeployHelperFactory();
        DeployHelper deployHelper = deployHelperFactory.getOrCreateDeployHelper(chainId);
        return deployHelper.getDeployConfig(chainId);
    }
}
