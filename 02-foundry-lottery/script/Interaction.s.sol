// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {Constants} from "./library/Constants.sol";
import {DeployContextHolder} from "./util/DeployContextHolder.sol";
import {Script, console2} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mock/LinkToken.sol";

error Interaction__InvalidSubscriptionId(uint256 subId);

contract BaseInteraction {

    function getDeployContext() internal returns (DeployContextHolder.DeployContext memory) {
        DeployContextHolder holder = new DeployContextHolder();
        return holder.getDeployContext();
    }
}

contract CreateSubscription is Script, BaseInteraction {

    event BlockNumber(uint256 indexed blockNumber);

    function run() external {
        createSubscriptionUsingContext();
    }

    function createSubscription(address vrfCoordinatorAddress, address sender) public returns (uint256) {
        console2.log("Create subscription");
        console2.log("Sender:", sender);
        console2.log("VrfCoordinator address:", vrfCoordinatorAddress);
        vm.startBroadcast(sender);
        VRFCoordinatorV2_5Mock vrfCoordinatorMock = VRFCoordinatorV2_5Mock(vrfCoordinatorAddress);
        uint256 subId = vrfCoordinatorMock.createSubscription();
        vm.stopBroadcast();
        console2.log("New subscription created");
        console2.log("Subscription id:", subId);
        return subId;
    }

    function createSubscriptionUsingContext() public returns (uint256) {
        DeployContextHolder.DeployContext memory context = getDeployContext();
        return createSubscription(context.vrfCoordinatorAddress, context.account);
    }
}

contract FundSubscription is Script, BaseInteraction {

    function run() external {
        vm.stopBroadcast();
    }

    function fundSubscription(
        uint256 subId,
        address vrfCoordinatorAddress,
        address linkTokenAddress,
        uint256 value,
        address sender
    ) public {
        console2.log("Fund subscription");
        console2.log("Sender:", sender);
        console2.log("Subscription id:", subId);
        console2.log("LinkToken address:", linkTokenAddress);
        console2.log("Value:", value);
        console2.log("VrfCoordinator address:", vrfCoordinatorAddress);
        if (subId == 0) {
            revert Interaction__InvalidSubscriptionId(subId);
        }
        if (block.chainid == Constants.ANVIL_CHAIN_ID) {
            vm.startBroadcast(sender);
            VRFCoordinatorV2_5Mock vrfCoordinatorMock = VRFCoordinatorV2_5Mock(vrfCoordinatorAddress);
            vrfCoordinatorMock.fundSubscription(subId, value);
            vm.stopBroadcast();
            console2.log("Subscription funded, value:");
            console2.log("Subscription id:", subId);
            console2.log("Value:", value);
        } else {
            vm.startBroadcast();
            LinkToken linkToken = LinkToken(linkTokenAddress);
            linkToken.transferAndCall(
                vrfCoordinatorAddress,
                value,
                abi.encode(subId));
            vm.stopBroadcast();
            console2.log("Subscription funded");

        }
    }

    function fundSubscriptionUsingConfig(uint256 value) public {
        DeployContextHolder.DeployContext memory context = getDeployContext();
        fundSubscription(
            context.subId,
            context.vrfCoordinatorAddress,
            context.linkTokenAddress,
            value,
            context.account);
    }
}

contract AddConsumer is Script, BaseInteraction {

    function run() external {
        addConsumerUsingConfig();
    }

    function addConsumer(
        uint256 subId,
        address vrfCoordinatorAddress,
        address consumerAddress,
        address sender
    ) public {
        console2.log("Add consumer");
        console2.log("Sender:", sender);
        console2.log("Consumer address:", consumerAddress);
        console2.log("Subscription id:", subId);
        console2.log("VrfCoordinator address:", vrfCoordinatorAddress);
        if (subId == 0) {
            revert Interaction__InvalidSubscriptionId(subId);
        }
        vm.startBroadcast(sender);
        VRFCoordinatorV2_5Mock vrfCoordinatorMock = VRFCoordinatorV2_5Mock(vrfCoordinatorAddress);
        vrfCoordinatorMock.addConsumer(subId, consumerAddress);
        vm.stopBroadcast();
        console2.log("Consumer added");
    }

    function addConsumerUsingConfig() public {
        address raffleAddress = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        DeployContextHolder.DeployContext memory context = getDeployContext();
        addConsumer(
            context.subId,
            context.vrfCoordinatorAddress,
            raffleAddress,
            context.account);
    }
}