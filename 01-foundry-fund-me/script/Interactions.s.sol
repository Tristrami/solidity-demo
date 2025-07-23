// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {DeployFundMe} from "./DeployFundMe.s.sol";
import {FundMe} from "../src/FundMe.sol";
import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {

    uint256 private constant DEFAULT_SEND_AMOUNT = 1 ether;

    uint256 private constant DEFAULT_BALANCE = 10 ether;

    /**
     * 这个函数给命令行执行 forge script 时调用，使用 --sender 指定 transaction 的发送者
     */
    function run() external {
        vm.startBroadcast();
        fund(getLatestDeployedFundMeContract(), DEFAULT_SEND_AMOUNT);
        vm.stopBroadcast();
    }

    /**
     * 这个函数给测试脚本调用
     * @param fundMe FundMe 合约实例
     * @param sendAmount 发送的金额
     */
    function fund(FundMe fundMe, uint256 sendAmount) public {
        console.log("Sender: %s", msg.sender);
        console.log("Balance: %s", msg.sender.balance);
        require(address(fundMe) != address(0), "Unable to fund, FundMe contract is not specified");
        fundMe.fund{ value: sendAmount }();
    }

    function getLatestDeployedFundMeContract() internal view returns (FundMe) {
        return FundMe(payable(DevOpsTools.get_most_recent_deployment("FundMe", block.chainid)));
    }

}

contract WithdrawFundMe is Script {

    /**
     * 这个函数给命令行执行 forge script 时调用
     */
    function run() external {
        vm.startBroadcast();
        withdraw(getLatestDeployedFundMeContract());
        vm.stopBroadcast();
    }

    /**
     * 这个函数给测试脚本调用 
     * @param fundMe FundMe 合约实例
     */
    function withdraw(FundMe fundMe) public {
        require(address(fundMe) != address(0), "Unable to fund, FundMe contract is not specified");
        fundMe.withdraw();
    }

    function getLatestDeployedFundMeContract() internal view returns (FundMe) {
        return FundMe(payable(DevOpsTools.get_most_recent_deployment("FundMe", block.chainid)));
    }

}