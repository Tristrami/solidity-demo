-include .env

.PHONY: deploy-sepolia install test test-sepolia

install :; forge install cyfrin/foundry-devops@0.4.0 && forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 && forge install foundry-rs/forge-std@v1.8.2

deploy-anvil :
	@forge script script/DeployRaffle.s.sol --rpc-url $(LOCAL_RPC_URL) --account defaultKey --sender $(ANVIL_SENDER) -vvvv --broadcast

deploy-anvil-simulate :
	@forge script script/DeployRaffle.s.sol --rpc-url $(LOCAL_RPC_URL) --account defaultKey --sender $(ANVIL_SENDER) -vvvv

deploy-sepolia :
	@forge script script/DeployRaffle.s.sol --rpc-url $(SEPOLIA_RPC_URL) --account sepoliaKey --sender $(SEPOLIA_SENDER) -vvvv --broadcast

deploy-sepolia-simulate :
	@forge script script/DeployRaffle.s.sol --rpc-url $(SEPOLIA_RPC_URL) --account sepoliaKey --sender $(SEPOLIA_SENDER) -vvvv

test-sepolia :
	@forge test --fork-url $(SEPOLIA_RPC_URL) -vvvv --sender $(SEPOLIA_SENDER)
