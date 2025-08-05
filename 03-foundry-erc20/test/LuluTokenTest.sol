// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {LuluToken} from "src/LuluToken.sol";
import {DeployLuluToken} from "script/DeployLuluToken.s.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract LuluTokenTest is Test, IERC20Errors {

    uint256 private constant TRANSFER_AMOUNT = 10 ether;

    LuluToken private luluToken;
    DeployLuluToken private deployer;
    address private lulu;
    address private lan;

    constructor() {
        deployer = new DeployLuluToken();
        lulu = makeAddr("lulu");
        lan = makeAddr("lan");
    }

    function setUp() external {
        vm.startBroadcast();
        luluToken = deployer.deploy();
        vm.stopBroadcast();
        vm.deal(lulu, 0);
        vm.deal(lan, 0);
    }

    function testTransfer() public {
        uint256 totalSupply = luluToken.totalSupply();
        vm.prank(address(deployer));
        luluToken.transfer(lulu, TRANSFER_AMOUNT);
        assertEq(luluToken.balanceOf(lulu), TRANSFER_AMOUNT);
        assertEq(luluToken.balanceOf(address(deployer)), totalSupply - TRANSFER_AMOUNT);
    }

    function test_TransferFromWithAllowance() public {
        vm.prank(address(deployer));
        luluToken.transfer(lulu, TRANSFER_AMOUNT);
        uint256 startingLuluBalance = luluToken.balanceOf(lulu);
        uint256 startingLanBalance = luluToken.balanceOf(lan);
        vm.prank(lulu);
        luluToken.approve(lan, TRANSFER_AMOUNT);
        vm.prank(lan);
        luluToken.transferFrom(lulu, lan, TRANSFER_AMOUNT);
        uint256 endingLuluBalance = luluToken.balanceOf(lulu);
        uint256 endingLanBalance = luluToken.balanceOf(lan);
        assertEq(endingLuluBalance, startingLuluBalance - TRANSFER_AMOUNT);
        assertEq(endingLanBalance, startingLanBalance + TRANSFER_AMOUNT);
    }

    function test_RevertWhen_AllowanceExceeded() public {
        vm.prank(address(deployer));
        luluToken.transfer(lulu, TRANSFER_AMOUNT);
        vm.prank(lulu);
        luluToken.approve(lan, TRANSFER_AMOUNT);
        bytes memory revertData = abi.encodeWithSelector(
            ERC20InsufficientAllowance.selector,
            lan,
            luluToken.allowance(lulu, lan),
            TRANSFER_AMOUNT + 1
        );
        vm.prank(lan);
        vm.expectRevert(revertData);
        luluToken.transferFrom(lulu, lan, TRANSFER_AMOUNT + 1);
    }

}