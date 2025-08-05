# Foundry Lottery

## ChainLink VRF

订阅列表：https://vrf.chain.link/sepolia

## 坑

- 使用 `vm.startBroadcast()` 进行广播时，一定只在 **需要修改链上数据** 的代码范围内开启广播，否则可能会造成奇怪的数据问题
- 使用 `forge script` 部署时，如果指定了 `--rpc-url` 参数，CheatCode 只有在 Foundry 模拟 EVM 中执行时可以生效，在链上执行的阶段是不会生效的，即使是自己启动的 Anvil 链
- 本地启动的 Anvil 链，区块编号默认一直是 0，在执行某些操作时可能会报错，例如 `VRFCoordinatorV2_5Mock` 中的 `createSubscription` 函数，有一个 `block.number - 1` 的操作，会造成下溢，可以通过手动挖一个新区块解决
  - 查看当前区块号: `cast block-number --rpc-url http://localhost:8545`
  - 挖一个新区块：`cast rpc evm_mine --rpc-url http://localhost:8545`
- 部署到 Sepolia 最好用创建好的 Subscription，自动创建的话，本地模拟阶段和 RPC 模拟阶段存在时间差，subId 的创建逻辑依赖上一个区块的 blockhash，如果中间有交易的话，生成的 subId 会不同，导致模拟失败

### Foundry 脚本部署流程

本地模拟（dry-run）-- RPC 模拟 -- 广播

本地模拟阶段，代码均在本地 EVM 模拟环境执行，生成交易数据，生成的数据和 dry-run 日志文件里差不多

RPC 模拟阶段，根据交易数据，调用 RPC 接口发送交易，在链上模拟执行，并不会改变链上状态

### 手动验证合约

Sepolia Raffle 合约地址

```solidity
0xd9241799F64BE2685865555085a094D77220e32A
0x6a6fB40D129dE7ee710824239E65fC643C2D9A68
0xf212d9197cb9D2f2E2D2D30EBEBe34B85A821df7
```

测试网可能部署时自动验证会有问题，使用 etherscan API，把 standard input 提取出来，然后再去网页上手动验证

```shell
forge verify-contract 0xf212d9197cb9D2f2E2D2D30EBEBe34B85A821df7 src/Raffle.sol:Raffle --etherscan-api-key $ETHERSCAN_API_KEY --rpc-url $SEPOLIA_RPC_URL --show-standard-json-input > input.json
```

调用方法

查看 `entranceFee`

```shell
cast call 0xf212d9197cb9D2f2E2D2D30EBEBe34B85A821df7 "getEntranceFee()" --rpc-url $SEPOLIA_RPC_URL --account sepoliaKey
```

进入 `Raffle`

```shell
cast send 0xf212d9197cb9D2f2E2D2D30EBEBe34B85A821df7 "enterRaffle()" --value "0.01 ether" --rpc-url $SEPOLIA_RPC_URL --account sepoliaKey
```

获取 `Raffle` 状态

```shell
cast send 0xf212d9197cb9D2f2E2D2D30EBEBe34B85A821df7 "enterRaffle()" --value "0.01 ether" --rpc-url $SEPOLIA_RPC_URL --account sepoliaKey
```

获取玩家

```shell
cast call 0xf212d9197cb9D2f2E2D2D30EBEBe34B85A821df7 "getPlayer(uint256)" 0 --rpc-url $SEPOLIA_RPC_URL --account sepoliaKey
```