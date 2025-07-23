// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
Contract elements should be laid out in the following order:
Pragma statements
Import statements
Events
Errors
Interfaces
Libraries
Contacts

Inside each contract, library or interface, use the following order:
Type declarations
State variables
Events
Errors
Modifiers
Functions
 */

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";

error Raffle__NotOpen();
error Raffle__NotEnoughMoney(uint256 entranceFee);
error Raffle__InvalidPlayerAddress(address playerAddress);
error Raffle__PrizePoolIsEmpty();
error Raffle__PrizeSendFailed();
error Raffle__NoPlayer();
error Raffle__NotLotteryDrawTime();

contract Raffle is VRFConsumerBaseV2Plus, AutomationCompatibleInterface {

    enum RaffleState { OPEN, CALCULATING }

    uint256 private constant BLOCK_CONFIRMATIONS = 3;
    uint256 private constant NUM_WORDS = 1;
    uint256 private constant CALLBACK_GAS_LIMIT = 15000;

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;

    // vrfCoordinator 大概相当于一个网关的角色，在合约和链下 vrf 服务中间传递信息
    address private immutable i_vrfCoordinatorAddress;
    // vrf 的订阅合约地址
    address private immutable i_subscriptionId;
    // gasLane 地址，用于指定 gasLimit
    address private immutable i_gasLane;

    address payable[] private s_players;
    uint256 private s_lastTimestamp;
    RaffleState private s_raffleState;

    event RaffleEntered(address indexed playerAddress, uint256 indexed value);
    event WinnerPicked(address indexed winnerAddress);
    event LotteryPrizeSent(address indexed winnerAddress, uint256 prizePoolAmount);
    event RaffleOpened(uint256 timestamp);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinatorAddress,
        address subscriptionId,
        address keyHash
    ) VRFConsumerBaseV2Plus(vrfCoordinatorAddress) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_vrfCoordinatorAddress = vrfCoordinatorAddress;
        i_subscriptionId = subscriptionId;
        i_gasLane = keyHash;
        openRaffle();
    }

    function enterRaffle() external payable {
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__NotOpen();
        }
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughMoney(i_entranceFee);
        }
        s_players.push(payable(msg.sender));
    }

    function startCalculatingWinner() internal {
        if (!shouldStartCalculatingWinner()) {
            revert Raffle__NotLotteryDrawTime();
        }
        s_raffleState = RaffleState.CALCULATING;
        uint256 requestID = s_vrfCoordinator.requestRandomWords(createRandomWordsRequest());
    }

    function shouldStartCalculatingWinner() internal view returns (bool) {
        bool hasPlayer = s_players.length > 0;
        bool hasBalance = address(this).balance > 0;
        bool intervalPassed = block.timestamp - s_lastTimestamp >= i_interval;
        return hasPlayer && hasBalance && intervalPassed;
    }

    function createRandomWordsRequest() internal view returns (VRFV2PlusClient.RandomWordsRequest) {
        return VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_gasLane,
            subId: i_subscriptionId,
            requestConfirmations: BLOCK_CONFIRMATIONS,
            callbackGasLimit: CALLBACK_GAS_LIMIT,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: true}))
        });
    }

    function getWinner(uint256 randomNumber) internal returns (address payable) {
        if (address(this).balance == 0) {
            revert Raffle__PrizePoolIsEmpty();
        }
        if (s_players.length == 0) {
            revert Raffle__NoPlayer();
        }
        uint256 playerIndex = randomNumber % s_players.length;
        address payable winnerAddress = s_players[playerIndex];
        emit WinnerPicked(winnerAddress);
        return winnerAddress;
    }

    function sendLotteryPrizeToWinner(address payable winnerAddress) internal {
        if (winnerAddress == address(0)) {
            revert Raffle__InvalidPlayerAddress(winnerAddress);
        }
        if (address(this).balance == 0) {
            revert Raffle__PrizePoolIsEmpty();
        }
        uint256 balance = address(this).balance;
        (bool callSuccess, ) = winnerAddress.call{ value: balance }("");
        emit LotteryPrizeSent(winnerAddress, balance);
        if (!callSuccess) {
            revert Raffle__PrizeSendFailed();
        }
    }

    function openRaffle() internal {
        uint256 currentTimestamp = block.timestamp;
        s_players = new address payable[](0);
        s_lastTimestamp = currentTimestamp;
        s_raffleState = RaffleState.OPEN;
        emit RaffleOpened(currentTimestamp);
    }

    function fulfillRandomWords(uint256 /* requestId */, uint256[] calldata randomWords) internal override {
        address payable winnerAddress = getWinner(randomWords[0]);
        sendLotteryPrizeToWinner(winnerAddress);
        openRaffle();
    }

    function checkUpkeep(bytes calldata checkData)
        external
        override
        returns (bool upkeepNeeded, bytes memory /* performData */) {
        upkeepNeeded = shouldStartCalculatingWinner();
        return upkeepNeeded;
    }

    function performUpkeep(bytes calldata performData) external override {
        startCalculatingWinner();
    }

}