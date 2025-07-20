// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMe} from "../../src/FundMe.sol";

contract FundMeIntegrationTest is Test {

    uint256 private constant DEFAULT_SEND_VALUE = 1 ether;

    uint256 private constant DEFAULT_BALANCE = 10 ether;

    FundFundMe private fundFundMe;

    WithdrawFundMe private withdrawFundMe;

    address private testSender = makeAddr("testSender");

    FundMe private fundMe;

    function setUp() external {
        initializeInteractionContract();
        initializeSenderBalance();
        deployFundMeContract();    
    }

    function initializeInteractionContract() private {
        fundFundMe = new FundFundMe();
        withdrawFundMe = new WithdrawFundMe();
    }

    function initializeSenderBalance() private {
        vm.deal(testSender, DEFAULT_BALANCE);
    }

    function deployFundMeContract() private {
        (FundMe fundMeContract, ) = new DeployFundMe().run();
        fundMe = fundMeContract;
    }

    function testFundAndWithdraw() public {
        // Arrange
        address owner = fundMe.getOwner();
        uint256 startingOwnerBalance = owner.balance;
        uint256 startingSenderBalance = testSender.balance;
        // Act
        vm.prank(testSender);
        fundMe.fund{ value: DEFAULT_SEND_VALUE }();
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // Assert
        uint256 enddingOwnerBalance = owner.balance;
        uint256 enddingContractBalance = address(fundMe).balance;
        uint256 enddingSenderBalance = testSender.balance;

        assertEq(enddingOwnerBalance, startingOwnerBalance + DEFAULT_SEND_VALUE);
        assertEq(enddingContractBalance, 0);
        assertEq(enddingSenderBalance, startingSenderBalance - DEFAULT_SEND_VALUE);
    }
}
