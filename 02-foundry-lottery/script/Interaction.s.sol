// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {VrfSubscriptionManager} from "./util/VrfSubscriptionManager.sol";
import {BroadcastScript} from "./util/BroadcastScript.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {Raffle} from "src/Raffle.sol";
import {DeployHelperFactory} from "./util/DeployHelperFactory.sol";

contract DeployDeployHelper is BroadcastScript {

    function run() external {
        DeployHelperFactory factory = new DeployHelperFactory();
        factory.deploy();
    }
}

contract CreateSubscription is BroadcastScript {

    function run() external {
        VrfSubscriptionManager manager = new VrfSubscriptionManager();
        manager.getOrCreateSubscription(block.chainid);
    }
}

contract FundSubscription is BroadcastScript {

    function run() external {
        VrfSubscriptionManager manager = new VrfSubscriptionManager();
        manager.fundSubscription(block.chainid);
    }
}

contract AddConsumer is BroadcastScript {

    function run() external {
        Raffle raffle = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        VrfSubscriptionManager manager = new VrfSubscriptionManager();
        manager.addConsumer(address(raffle), block.chainid);
    }
}