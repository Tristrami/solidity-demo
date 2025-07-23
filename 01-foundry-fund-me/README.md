# Foundry Fund Me

## 项目配置

### 外部依赖引入问题

`AggeragatorV3Interface` 原来的引入方式

```solidity
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
```

Foundry 不能和 Remix 一样直接解析这种 import，需要使用 `forge install` 将依赖的合约下载到 `lib` 目录中

```shell
forge install smartcontractkit/chainlink-brownie-contracts@1.3.0 --no-commit
```

将 `@chainlink` 前缀映射到 `lib/chainlink-brownie-contracts` 目录，需要在 `foundry.toml` 中配置

```toml
remappings = ["@chainlink/contracts=lib/chainlink-brownie-contracts/contracts"]
```

重新编译项目

```shell
forge compile
```

## 测试脚本

### 测试分类

- **Unit tests**: Focus on isolating and testing individual smart contract      functions or functionalities.
- **Integration tests**: Verify how a smart contract interacts with other contracts or external systems.
- **Forking tests**: Forking refers to creating a copy of a blockchain state at a specific point in time. This copy, called a fork, is then used to run tests in a simulated environment.
- **Staging tests**: Execute tests against a deployed smart contract on a staging environment before mainnet deployment.

### 本地网络测试

在 `test` 目录下新建合约，继承 `Test` 合约，然后运行测试脚本，此时 Foundry 会启动一个临时的 anvil 本地网络，运行完成后关闭

- `--match-test` 表示通过正则匹配测试函数，只运行匹配上的测试函数
- `-vvv` 表示日志等级，v 越多日志越详细

```shell
forge test --match-test functionName -vvv
```

#### 测试执行流程

每个测试函数执行之前，Foundry 都会运行一次 `setup` 函数，初始化完成后，再进行测试，也就是说，如果 `setup` 中创建了合约实例，每次测试都会使用新的合约实例，测试间合约状态变量互不干扰

### 模拟 Sepolia 测试网络

在执行测试脚本时，可以使用 `--fork-url` 指定网络的 rpc url，anvil 会复制一个网络用于测试，可以解决 priceFeed 相关合约在本地网络不存在的问题，缺点是会发起大量的 api call，所以尽可能的在需要的时候再做 fork test

```shell
forge test --fork-url $SEPOLIA_RPC_URL -vvv
```

### 覆盖测试

可以看测试函数覆盖了百分之多少的代码

```shell
forge coverage --fork-url $SEPOLIA_RPC_URL -vvv
```

输出的测试结果

```shell
Ran 1 test suite in 6.41s (4.78s CPU time): 4 tests passed, 0 failed, 0 skipped (4 total tests)

╭---------------------------+----------------+----------------+---------------+---------------╮
| File                      | % Lines        | % Statements   | % Branches    | % Funcs       |
+=============================================================================================+
| script/DeployFundMe.s.sol | 0.00% (0/4)    | 0.00% (0/3)    | 100.00% (0/0) | 0.00% (0/1)   |
|---------------------------+----------------+----------------+---------------+---------------|
| src/FundMe.sol            | 40.00% (8/20)  | 31.25% (5/16)  | 16.67% (1/6)  | 42.86% (3/7)  |
|---------------------------+----------------+----------------+---------------+---------------|
| src/PriceConverter.sol    | 100.00% (6/6)  | 100.00% (6/6)  | 100.00% (0/0) | 100.00% (2/2) |
|---------------------------+----------------+----------------+---------------+---------------|
| Total                     | 46.67% (14/30) | 44.00% (11/25) | 16.67% (1/6)  | 50.00% (5/10) |
╰---------------------------+----------------+----------------+---------------+---------------╯
```

### Cheat Code

> Cheat Code Reference：https://getfoundry.sh/reference/cheatcodes/overview

#### Cheat Code 分类

- Environment: Cheatcodes that alter the state of the EVM.
- Assertions: Cheatcodes that are powerful assertions
- Fuzzer: Cheatcodes that configure the fuzzer
- External: Cheatcodes that interact with external state (files, commands, ...)
- Signing: Cheatcodes for signing
- Utilities: Smaller utility cheatcodes
- Forking: Forking mode cheatcodes
- State snapshots: State snapshot cheatcodes
- RPC: RPC related cheatcodes
- File: Cheatcodes for working with files

#### 常用 Cheat Code

- `vm.startBroadcast()`，`vm.stopBroadcast()`：将在这之间的 transaction 将会被广播到区块链上
- `vm.expectRevert()`：下面一行代码执行后需要 revert
- `vm.prank(senderAddress)`：将下次 call 的 `msg.sender` 设置为指定的地址
- `vm.startPrank(senderAddress)`，`vm.stopPrank()`：将在这之间的所有 call 的 `msg.sender` 设置为指定的地址
- `vm.deal(accountAddress, balance)`：设置账户的余额

### 指定测试中交易的发送者

使用 `forge-std` 库中的 `makeAddr` 函数创建一个账户

```solidity
address defaultSender = makeAddr("defaultSender");
```

给账户设置初始的余额，`1 ether` 等于 `1e18`

```solidity
vm.deal(defaultSender, 10 ether);
```

使用创建的账户发送交易

```solidity
vm.prank(defaultSender);
```

`forge-std` 库中的 `hoax(sender, balance)` 可以完成 `vm.prank()` 和 `vm.deal()` 的功能，设置下一个交易的发送者为 `sender`，并设置 `sender` 账户的余额为 `balance`

```solidity
hoax(defaultSender, balance)
```

将整数转换为地址，`uint160` 整数和 `address` 类型的位数相同，可以转换，注意最好不要用 `address(0)`，因为这个是 `address` 类型的默认值

```solidity
uint160 number = 1;
address sender = address(number);
```

## Gas 优化

### EVM 内存结构

| 类型       | 持久性 | 可变性 | Gas 成本 | 作用域         | 典型用途             |
|------------|--------|--------|----------|----------------|----------------------|
| **Storage**   | 永久   | 可读写 | 高       | 合约级别       | 状态变量             |
| **Memory**    | 临时   | 可读写 | 中       | 函数调用级别   | 函数内临时变量       |
| **Stack**     | 瞬时   | 可读写 | 低       | 指令级别       | EVM 操作中间结果     |
| **Calldata**  | 临时   | 只读   | 低       | 交易级别       | 函数参数             |
| **Code**      | 永久   | 只读   | 固定     | 合约级别       | 合约字节码           |

存储在 **Storage** 中的数据需要使用 `SLOAD` 和 `SSTORE` 指令进行加载和读取，这两个指令消耗的 Gas 较高，所以要尽量避免频繁读取或写入 **Storage** 内存

EVM 指令及消耗的 Gas：https://www.evm.codes/

### Storage 内存结构

Storage 内存类似一个数组，每个 Slot 大小为 32 字节，变量按声明顺序依次占用存储槽

- 数组类型变量，数组长度存储在 Slot p，数组元素存储在 keccak256(p) 开始的连续 Slot 中
- Mapping 类型变量，slot 是空的，键 k 对应的值存储在 keccak256(h(k) . p)，其中 p 是映射的 Slot 位置，h 是键的哈希函数
- 父合约的变量优先占用低编号 Slot，子合约变量依次向后排列
- constant 和 immutable 修饰的变量不会放到 Storage 内存中，它们都会被直接放到合约的字节码中

### 查看 Gas 消耗情况

查看测试函数消耗的 Gas，结果会保存到项目根目录下的 `.gas-snapshot` 文件中

```shell
forge snapshot
```

获取当前的 Gas 费用

```solidity
vm.txGasPrice(); // Foundry Cheat Code
tx.gasprice(); // Solidity
```

查看当前交易剩余 Gas，这个是 solidity 原生支持的函数

```solidity
gasLeft();
```

### 查看 Storage 内存

查看 Storage 内存槽存储的数据

```shell
cast storage <contractAddress> <slotNumber> --rpc-url xxx
```

查看合约的 Storage 内存布局

```shell
forge inspect FundMe storageLayout
```

输出结果

```
╭------------------------+--------------------------------+------+--------+-------+-----------------------╮
| Name                   | Type                           | Slot | Offset | Bytes | Contract              |
+=========================================================================================================+
| s_funderToAmountFunded | mapping(address => uint256)    | 0    | 0      | 32    | src/FundMe.sol:FundMe |
|------------------------+--------------------------------+------+--------+-------+-----------------------|
| s_funders              | address[]                      | 1    | 0      | 32    | src/FundMe.sol:FundMe |
|------------------------+--------------------------------+------+--------+-------+-----------------------|
| s_priceFeed            | contract AggregatorV3Interface | 2    | 0      | 20    | src/FundMe.sol:FundMe |
╰------------------------+--------------------------------+------+--------+-------+-----------------------╯
```

## 验证部署的合约

部署合约时，使用 EtherScan 的 api 验证合约

```shell
forge script ... --verify --etherscan-api-key $ETHERSCAN_API_KEY
```


## 使用 Makefile 简化命令行操作

参考项目目录下的 `Makefile` 文件

## Function Selector

通过 `cast` 可以查看函数的十六进制函数签名

```shell
cast sig "fund()"
```