// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Script} from "forge-std/Script.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract DeploySimpleStorage is Script {

    function run() external returns(SimpleStorage) {
        // 把需要和区块链交互的操作放在 start 和 stop 中间，start 之前的操作都只会模拟执行，
        // 不会发送 transaction，start 之后的操作会向链上发送真正的 transaction
        vm.startBroadcast();
        // new 关键字会在链上创建一个智能合约实例
        SimpleStorage simpleStorage = new SimpleStorage();
        vm.stopBroadcast();
        return simpleStorage;
    }

}