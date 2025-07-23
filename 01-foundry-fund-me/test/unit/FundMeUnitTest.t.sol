// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {NetworkConfigHelper} from "../../script/NetworkConfigHelper.s.sol";

contract FundMeUnitTest is Test {

    FundMe private fundMe;

    NetworkConfigHelper private networkConfigHelper;

    address private defaultSender = makeAddr("defaultSender");

    uint256 private constant STARTING_BALANCE = 10 ether;

    uint256 private constant SEND_AMOUNT = 1 ether;

    modifier Funded {
        vm.prank(defaultSender);
        fundMe.fund{ value: SEND_AMOUNT }();
        _;
    }

    /**
     * 每个测试函数执行前都回重新执行 setup
     */
    function setUp() external {
        networkConfigHelper = new NetworkConfigHelper();
        address priceFeedAddress = networkConfigHelper.getActiveNetworkConfig().priceFeedAddress;
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run(priceFeedAddress);
        // 为 defaultSender 账户设置余额
        vm.deal(defaultSender, STARTING_BALANCE);
    }

    function testOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFunders() public Funded {
        vm.assertEq(fundMe.getFunder(0), defaultSender);
    }

    function testFundUpdatesFunderToAmountFunded() public Funded {
        vm.assertEq(fundMe.getAmountFunded(defaultSender), SEND_AMOUNT);
    }

    function testOnlyOwnerCanWithdraw() public Funded {
        vm.prank(address(this));
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawFromSingleFunder() public Funded {
        // Arrange
        address contractOwner = fundMe.getOwner();
        uint256 startingContractBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = contractOwner.balance;
        // Act
        vm.prank(contractOwner);
        fundMe.withdraw();
        // Assert
        uint256 endingContractBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = contractOwner.balance;
        assertEq(endingContractBalance, 0);
        assertEq(endingOwnerBalance, startingContractBalance + startingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public {
        // Arrange
        for (uint160 i = 1; i <= 5; i++) {
            hoax(address(i), SEND_AMOUNT);
            fundMe.fund{ value: SEND_AMOUNT }();
        }
        address contractOwner = fundMe.getOwner();
        uint256 startingContractBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = contractOwner.balance;
        // Act
        vm.prank(contractOwner);
        fundMe.withdraw();
        // Assert
        uint256 endingContractBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = contractOwner.balance;
        assertEq(endingContractBalance, 0);
        assertEq(endingOwnerBalance, startingContractBalance + startingOwnerBalance);
    }

}
