// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DeployContextHolder} from "./util/DeployContextHolder.sol";
import {Raffle} from "src/Raffle.sol";
import {Script, console2} from "forge-std/Script.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interaction.s.sol";
import {Constants} from "./library/Constants.sol";

contract DeployRaffle is Script {

    CreateSubscription private createSubscription;
    FundSubscription private fundSubscription;
    AddConsumer private addConsumer;

    constructor() {
        createSubscription = new CreateSubscription();
        fundSubscription = new FundSubscription();
        addConsumer = new AddConsumer();
    }

    function run() external {
        console2.log("Start deploying raffle");
        DeployContextHolder contextHolder = new DeployContextHolder();
        DeployContextHolder.DeployContext memory context = contextHolder.getDeployContext();
        console2.log("Subscription id:", context.subId);
        if (context.subId == 0) {
            context.subId = createSubscription.createSubscription(
                context.vrfCoordinatorAddress,
                context.account);
            console2.log("Created new subscription, subId:", context.subId);
        }
        Raffle raffle = deploy(context);
        console2.log("Raffle deployed to", address(raffle));
        addConsumer.addConsumer(
            context.subId,
            context.vrfCoordinatorAddress,
            address(raffle),
            context.account);
        if (block.chainid == Constants.ANVIL_CHAIN_ID) {
            fundSubscription.fundSubscription(
                context.subId,
                context.vrfCoordinatorAddress,
                context.linkTokenAddress,
                Constants.DEFAULT_LOCAL_NET_FUND_AMOUNT,
                context.account);
        }
    }

    function deploy(DeployContextHolder.DeployContext memory deployContext) public returns (Raffle) {
        vm.startBroadcast(deployContext.account);
        Raffle raffle = new Raffle(
            deployContext.entranceFee,
            deployContext.interval,
            deployContext.vrfCoordinatorAddress,
            deployContext.subId,
            deployContext.keyHash
        );
        vm.stopBroadcast();
        return raffle;
    }
}
