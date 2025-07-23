// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Raffle} from "src/Raffle.sol";
import {BroadcastScript} from "./util/BroadcastScript.sol";
import {DeployHelperFactory} from "./util/DeployHelperFactory.sol";
import {DeployHelper} from "./util/DeployHelper.sol";

contract DeployRaffle is BroadcastScript {

    function run() external {
        deploy();
    }

    function deploy() public broadcast returns (Raffle) {
        DeployHelperFactory deployHelperFactory = new DeployHelperFactory();
        DeployHelper deployHelper = deployHelperFactory.getOrCreateDeployHelper(block.chainid);
        DeployHelper.DeployConfig memory deployConfig = deployHelper.getDeployConfig(block.chainid);
        Raffle raffle = new Raffle(
            deployConfig.entranceFee,
            deployConfig.interval,
            deployConfig.vrfCoordinatorAddress,
            deployConfig.subscriptionId,
            deployConfig.keyHash
        );
        return raffle;
    }
}
