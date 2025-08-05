// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {LuluToken} from "src/LuluToken.sol";

contract DeployLuluToken is Script {

    function run() external {
        vm.startBroadcast();
        deploy();
        vm.stopBroadcast();
    }

    function deploy() public returns (LuluToken) {
        return new LuluToken();
    }
}