// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console2} from "forge-std/Test.sol";
import {MiaoEngine} from "../../../src/MiaoEngine.sol";
import {MiaoToken} from "../../../src/MiaoToken.sol";
import {Validator} from "../../../src/Validator.sol";
import {DeployMiaoEngine} from "../../../script/DeployMiaoEngine.s.sol";
import {Constants} from "../../../script/util/Constants.sol";
import {DeployHelper} from "../../../script/util/DeployHelper.sol";
import {ERC20Mock} from "../../../test/mocks/ERC20Mock.sol";
import {MockV3Aggregator} from "../../../test/mocks/MockV3Aggregator.sol";
import {IERC20} from "@openzeppelin/contracts/token/erc20/IERC20.sol";

contract ContinueOnRevertHandler is Test {
    MiaoEngine private miaoEngine;
    MiaoToken private miaoToken;
    address[] private tokenAddresses;

    constructor(MiaoEngine _miaoEngine, MiaoToken _miaoToken) {
        miaoEngine = _miaoEngine;
        miaoToken = _miaoToken;
        tokenAddresses = miaoEngine.getCollateralTokenAddressess();
    }

    function deposit(uint8 collateralTokenAddressSeed, uint96 amountCollateral, uint96 amountMiaoToMint) public {
        // bound(amountCollateral, 1, type(uint96).max);
        // bound(amountMiaoToMint, 1, type(uint96).max);
        address tokenAddress = pickRandomTokenAddress(collateralTokenAddressSeed);
        ERC20Mock token = ERC20Mock(tokenAddress);
        token.mint(msg.sender, amountCollateral);
        // The sender will be this handler contract if without prank
        vm.startPrank(msg.sender);
        token.approve(address(miaoEngine), amountCollateral);
        miaoEngine.depositCollateralAndMintMiaoToken(tokenAddress, amountCollateral, amountMiaoToMint);
    }

    function redeem(
        uint8 collateralTokenAddressSeed,
        address collateralFrom,
        uint256 amountCollateralToRedeem,
        uint256 amountMiaoToBurn
    ) public {
        address tokenAddress = pickRandomTokenAddress(collateralTokenAddressSeed);
        uint256 amountDeposited = miaoEngine.getCollateralAmount(collateralFrom, tokenAddress);
        vm.assume(amountDeposited > 0);
        uint256 miaoBalance = miaoToken.balanceOf(msg.sender);
        vm.assume(miaoBalance > 0);
        // bound(amountCollateralToRedeem, 1, amountDeposited);
        // bound(amountMiaoToBurn, 1, miaoBalance);
        miaoEngine.redeemCollateral(tokenAddress, collateralFrom, amountCollateralToRedeem, amountMiaoToBurn);
    }

    function liquidate(address user, uint8 collateralTokenAddressSeed, uint256 debtToCover) public {
        address tokenAddreses = pickRandomTokenAddress(collateralTokenAddressSeed);
        uint256 miaoMinted = miaoEngine.getMiaoTokenMinted(user);
        vm.assume(miaoMinted > 0);
        bound(debtToCover, 1, miaoMinted);
        miaoEngine.liquidate(user, tokenAddreses, debtToCover);
    }

    function pickRandomTokenAddress(uint8 tokenSeed) private view returns (address) {
        return tokenAddresses[tokenSeed % tokenAddresses.length];
    }
}
