// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {Raffle} from "src/Raffle.sol";
import {DeployHelper} from "script/util/DeployHelper.sol";
import {DeployHelperFactory} from "script/util/DeployHelperFactory.sol";
import {Test} from "forge-std/Test.sol";

contract RaffleUnitTest is Test {

    uint256 private constant DEFAULT_BALANCE = 10 ether;
    uint256 private constant DEFAULT_SEND_VALUE = 1 ether;

    address private player;
    Raffle private raffle;
    DeployHelper.DeployConfig private deployConfig;

    function setUp() external {
        // 部署 Raffle 合约
        DeployRaffle deployRaffle = new DeployRaffle();
        raffle = deployRaffle.deploy();
        // 获取 deployConfig
        DeployHelperFactory deployHelperFactory = new DeployHelperFactory();
        DeployHelper deployHelper = deployHelperFactory.getOrCreateDeployHelper(block.chainid);
        deployConfig = deployHelper.getDeployConfig(block.chainid);
        // 初始化 player 账户地址和账户余额
        player = makeAddr("player");
        vm.deal(player, DEFAULT_BALANCE);
    }
}