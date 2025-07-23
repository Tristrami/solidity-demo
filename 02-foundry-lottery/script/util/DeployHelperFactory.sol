// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DeployHelper} from "./DeployHelper.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {BroadcastScript} from "./BroadcastScript.sol";

contract DeployHelperFactory is BroadcastScript {

    function getOrCreateDeployHelper(uint256 chainId) external returns (DeployHelper) {
        address deployHelperAddress = DevOpsTools.get_most_recent_deployment("DeployHelper", chainId);
        if (deployHelperAddress != address(0)) {
            console2.log("DeployHelper 合约已部署");
            return DeployHelper(deployHelperAddress);
        }
        console2.log("DeployHelper 合约未部署，开始部署合约");
        return DeployHelper(deploy());
    }

    function deploy() public broadcast returns (DeployHelper) {
        return new DeployHelper();
    }
}