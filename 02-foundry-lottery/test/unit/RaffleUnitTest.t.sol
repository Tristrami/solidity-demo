// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {Raffle} from "src/Raffle.sol";
import {DeployContextHolder} from "script/util/DeployContextHolder.sol";
import {Test} from "forge-std/Test.sol";
import {Constants} from "../../script/library/Constants.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {Vm} from "forge-std/Vm.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interaction.s.sol";

contract RaffleUnitTest is Test {

    uint256 private constant DEFAULT_BALANCE = 10 ether;
    uint256 private constant DEFAULT_SEND_VALUE = 1 ether;

    address private player;
    Raffle private raffle;
    DeployContextHolder.DeployContext private deployContext;
    CreateSubscription private createSubscription;
    FundSubscription private fundSubscription;
    AddConsumer private addConsumer;

    event RaffleEntered(address indexed playerAddress, uint256 indexed value);
    event WinnerPicked(address indexed winnerAddress);
    event LotteryPrizeSent(address indexed winnerAddress, uint256 indexed prizePoolAmount);
    event RaffleOpened(uint256 timestamp);
    event CalculatingStarted(uint256 indexed randomWordsRequestId);

    modifier raffleEntered {
        raffle.enterRaffle{value: DEFAULT_SEND_VALUE}();
        // 修改当前链时间
        vm.warp(block.timestamp + raffle.getInterval());
        // 修改区块数量，模拟真实场景，时间推移区块应该变多
        vm.roll(block.number + 1);
        _;
    }

    modifier localTest {
        if (block.chainid != Constants.ANVIL_CHAIN_ID) {
            return;
        }
        _;
    }

    constructor() {
        player = makeAddr("player");
        // 获取 deployContext
        DeployContextHolder contextHolder = new DeployContextHolder();
        deployContext = contextHolder.getDeployContext();
        // 初始化 Interaction.s.sol
        createSubscription = new CreateSubscription();
        fundSubscription = new FundSubscription();
        addConsumer = new AddConsumer();
    }

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        // 创建 vrf 订阅
        uint256 subId = createSubscription.createSubscription(
            deployContext.vrfCoordinatorAddress,
            deployContext.account);
        deployContext.subId = subId;
        // 部署 Raffle 合约
        raffle = deployRaffle.deploy(deployContext);
        // 把 raffle 添加到订阅的消费者中
        addConsumer.addConsumer(
            subId,
            deployContext.vrfCoordinatorAddress,
            address(raffle),
            deployContext.account);
        // 向订阅充值代币
        fundSubscription.fundSubscription(
            subId,
            deployContext.vrfCoordinatorAddress,
            deployContext.linkTokenAddress,
            Constants.DEFAULT_LOCAL_NET_FUND_AMOUNT,
            deployContext.account);
        // 初始化 player 账户余额
        vm.deal(player, DEFAULT_BALANCE);
    }

    function test_RaffleStateIsDefaultToOpen() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function test_RevertWhen_EnterRaffleWithNoETH() public {
        vm.expectRevert(abi.encodeWithSelector(Raffle.Raffle__NotEnoughMoney.selector, raffle.getEntranceFee()));
        raffle.enterRaffle();
    }

    function test_RevertWhen_EnterRaffleWithNotEnoughETH() public {
        vm.expectRevert(abi.encodeWithSelector(Raffle.Raffle__NotEnoughMoney.selector, raffle.getEntranceFee()));
        raffle.enterRaffle{value: 0.5 ether}();
    }

    function test_RevertWhen_EnterRaffleWhenRaffleIsCalculating() public raffleEntered {
        // 到开奖时间后，开始计算赢家，此时 Raffle 状态会被更改为 Calculating
        raffle.performUpkeep("");
        vm.expectRevert(Raffle.Raffle__NotOpen.selector);
        raffle.enterRaffle{value: DEFAULT_SEND_VALUE}();
    }

    function test_EnterRaffle() public {
        vm.prank(player);
        // 1 匹配事件签名 2 匹配第一个 indexed 参数 3 匹配第二个 indexed 参数 4 匹配其他非 indexed 参数
        vm.expectEmit(true, true, true, false);
        emit RaffleEntered(player, DEFAULT_SEND_VALUE);
        raffle.enterRaffle{value: DEFAULT_SEND_VALUE}();
        uint256 balance = address(raffle).balance;
        assertEq(balance, DEFAULT_SEND_VALUE);
        assertEq(raffle.getPlayer(0), address(player));
    }

    function test_DrawLotteryOnAnvil() public raffleEntered localTest {
        // 再加三个玩家参与彩票
        uint256 numPlayer = 3;
        uint256 prize = (numPlayer + 1) * DEFAULT_SEND_VALUE;
        address[] memory extraPlayers = new address[](numPlayer);
        uint256 winnerIndex = 1;
        for (uint160 i = 1; i <= numPlayer; i++) {
            address newPlayer = address(i);
            extraPlayers[i - 1] = newPlayer;
            hoax(newPlayer, DEFAULT_BALANCE);
            raffle.enterRaffle{value: DEFAULT_SEND_VALUE}();
        }
        address winner = extraPlayers[winnerIndex];
        uint256 startingWinnerBalance = winner.balance;
        uint256 startingRaffleBalance = address(raffle).balance;
        // 从获取随机数请求事件中，拿到请求 id
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log memory calculatingStarted = vm.getRecordedLogs()[1];
        uint256 requestId = uint256(calculatingStarted.topics[1]);
        // 调用随机数回调函数，假设第二个玩家是 winner
        uint256[] memory randomWords = new uint256[](1);
        randomWords[0] = winnerIndex + 1;
        VRFCoordinatorV2_5Mock vrfCoordinator = VRFCoordinatorV2_5Mock(deployContext.vrfCoordinatorAddress);

        // 校验事件
        vm.expectEmit(true, true, false, false);
        emit WinnerPicked(winner);
        vm.expectEmit(true, true, true, false);
        emit LotteryPrizeSent(winner, prize);
        vm.expectEmit(true, false, false, false);
        emit RaffleOpened(0);

        vrfCoordinator.fulfillRandomWordsWithOverride(requestId, address(raffle), randomWords);

        // 校验金额
        uint256 endingWinnerBalance = winner.balance;
        uint256 endingRaffleBalance = address(raffle).balance;
        assertEq(endingRaffleBalance, 0);
        assertEq(endingWinnerBalance, startingWinnerBalance + startingRaffleBalance);
    }
}