-include .env

.PHONY: deploy-sepolia install test test-sepolia rebuild

install :; forge install foundry-rs/forge-std@v1.8.2 && forge install OpenZeppelin/openzeppelin-contracts@v5.4.0

rebuild:
	@forge clean && @forge build

deploy-anvil :
	@forge script script/DeployLuluToken.s.sol --rpc-url $(LOCAL_RPC_URL) --account defaultKey --sender $(ANVIL_SENDER) -vvvv --broadcast

deploy-anvil-simulate :
	@forge script script/DeployLuluToken.s.sol --rpc-url $(LOCAL_RPC_URL) --account defaultKey --sender $(ANVIL_SENDER) -vvvv

deploy-sepolia :
	@forge script script/DeployLuluToken.s.sol --rpc-url $(SEPOLIA_RPC_URL) --account sepoliaKey --sender $(SEPOLIA_SENDER) -vvvv --broadcast

deploy-sepolia-simulate :
	@forge script script/DeployLuluToken.s.sol --rpc-url $(SEPOLIA_RPC_URL) --account sepoliaKey --sender $(SEPOLIA_SENDER) -vvvv

test:
	@forge test

test-sepolia :
	@forge test --fork-url $(SEPOLIA_RPC_URL) -vvvv --sender $(SEPOLIA_SENDER)
