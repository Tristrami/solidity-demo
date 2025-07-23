// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

contract BroadcastScript is Script {
    modifier broadcast {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }
}