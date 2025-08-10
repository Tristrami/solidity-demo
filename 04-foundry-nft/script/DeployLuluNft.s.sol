// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {LuluNft} from "src/LuluNft.sol";
import {Script} from "forge-std/Script.sol";

contract DeployLuluNft is Script {

    function run() external {
        vm.startBroadcast();
        deploy();
        vm.stopBroadcast();
    }

    function deploy() public returns (LuluNft) {
        return new LuluNft();
    }

    function baseUri() internal pure returns (string memory) {
        return "";
    }

}
