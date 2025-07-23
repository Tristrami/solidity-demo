// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {NetworkConfigHelper} from "./NetworkConfigHelper.s.sol";

contract DeployFundMe is Script {

    /**
     * 给命令行部署 FundMe 合约的时候用，不用传 priceFeedAddress
     */
    function run() external returns (FundMe, address) {
        NetworkConfigHelper networkConfigHelper = new NetworkConfigHelper();
        address priceFeedAddress = networkConfigHelper.getActiveNetworkConfig().priceFeedAddress;
        return (deployFundMe(priceFeedAddress), priceFeedAddress);
    }

    /**
     * 给测试脚本部署 FundMe 合约的时候用
     * @param priceFeedAddress priceFeed 的地址
     */
    function run(address priceFeedAddress) external returns (FundMe) {
        return deployFundMe(priceFeedAddress);
    }

    function deployFundMe(address priceFeedAddress) private returns (FundMe) {
        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeedAddress);
        vm.stopBroadcast();
        return fundMe;
    }
}