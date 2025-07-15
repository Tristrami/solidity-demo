# Foundry Simple Storage

## 初始化 Foundry 项目

```shell
forge init
```

## 启动本地区块链网络

启动后可以通过私钥将账户导入到钱包，并在钱包中添加本地区块链网络，默认 rpc url 为 `http://127.0.0.1:8545`

```shell
anvil
```

## 部署合约

### 私钥安全

#### 使用 foundry 中的 keystore 存储私钥

- 导入到 foundry wallet，执行命令后，将私钥粘贴到命令行，然后设置密码

```shell
cast wallet import defaultKey --interactive
```

- 查看所有 wallet

```shell
cast wallet list
```

- 部署合约时使用 `--account` 和 `--sender` （anvil虚拟钱包地址）参数替代私钥，命令执行后需要输入密码，也可以用 `--password-file` 参数指定存有密码的文件

```shell
forge script script/DeploySimpleStorage.s.sol --rpc-url http://localhost:8545 --account defaultKey --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --broadcast
```

- 查看 keystore 文件

```shell
less ~/.foundry/keystores/defaultKey
```

#### 其它安全措施

不能将私钥用明文存储，不能暴露到公网

清除命令行历史

```shell
history -c
```

清除 bash 历史文件

```shell
rm ~/.bash_history
```

### 编译合约

这个命令会编译 `src` 下的所有合约，编译后的文件放在 `out` 目录中

```shell
forge build
```

### 单个合约部署

- `--interactive` 参数可以在执行命令后出现一个互动界面，在里面可以输入 private key，比直接用参数输入更加安全，
- 加了 `--broadcast` 参数合约才会真正部署到链上，否则只是模拟
- 如果不加 `--rpc-url` 参数，foundry 会启动一个临时的本地链，然后将合约部署到上面，部署完成后关掉本地链

```shell
forge create SimpleStorage --rpc-url http://localhost:8545 --interactive --broadcast 
```

如果私钥使用 Foundry Wallet 中的账户，不需要加 `--sender` 参数

```shell
forge create SimpleStorage --rpc-url http://localhost:8545 --account defaultKey --broadcast
```

### 使用脚本部署

在 `script` 目录下创建部署脚本合约，继承 `Script` 接口，然后执行命令，部署完成后，可以在 `broadcast/<chainId>/run-latest.json` 文件中看到 transaction 的相关信息

有三个必要的参数：

- 区块链网关 URL `--rpc-url`
- Foundry Wallet 中导入的账户名称 `--account`
- 发送交易的账户地址 `--sender`
- 广播到区块链 `--broadcast`

```shell
forge script script/DeploySimpleStorage.s.sol --rpc-url http://localhost:8545 --account defaultKey --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --broadcast
```

Foundry 十六进制转换

```bash
cast --to-base 0x714c2 dec // 464066
```

将 rpc url 作为环境变量放到 `.env` 文件中

```
LOCAL_RPC_URL=http://localhost:8545
```

并使用 `source` 命令加载到内存，会更方便

```shell
source .env
```

### 部署到 Sepolia 测试网

#### 在 Foundry Wallet 中导入 Sepolia 私钥

```shell
cast wallet import sepoliaKey --interactive
```

#### 使用 Infura 区块链 RPC 网关云服务

```
https://sepolia.infura.io/v3/65d81b668ec04d3a801a03ed0cd8d385
```

#### 部署合约

```shell
forge script script/DeploySimpleStorage.s.sol --rpc-url https://sepolia.infura.io/v3/65d81b668ec04d3a801a03ed0cd8d385 --account sepoliaKey --sender 0x37CA3984F65bEB9400669c94faeEFaf1FC649964 --broadcast
```

#### 合约地址

```
0xca086d320a561e5d218617a3726436A66f023459
```

### 部署到本地 ZKsync 测试网

主要做这几件事情：

- 使用 foundry-zksync 编译合约
- 启动本地 ZKsync 测试网络
- 将合约部署到本地测试网络

#### 安装 Foundry ZKsync

安装 foundryup-zksync

```shell
curl -L https://raw.githubusercontent.com/matter-labs/foundry-zksync/main/install-foundry-zksync | bash
```

安装 foundry-zksync，安装后 foundry 的组件会被覆盖，例如 `cast` 和 `forge`，如果要切换回原生的 foundry，只需要重新用 `foundryup` 安装即可

```shell
foundryup-zksync
```

#### 编译合约

```shell
forge build --zksync
```

#### 配置本地 ZKsync 网络

安装 zksync-cli

```shell
npm install -g zksync-cli
```

配置本地链，选择启动 `anvil-zksync`

```shell
zksync-cli dev config
```

启动本地链，会创建一个 docker 容器

```shell
npx zksync-cli dev start
```

启动完成后，会看到这样的信息

```shell
anvil-zksync started v0.6.9:
 - ZKsync Node (L2):
  - Chain ID: 260
  - RPC URL: http://127.0.0.1:8011
  - Rich accounts: https://docs.zksync.io/zksync-era/tooling/local-setup/anvil-zksync-node#pre-configured-rich-wallets
 - Note: every restart will necessitate a reset of MetaMask's cached account data
```

#### 导入 ZKsync 账户到 Foundry Wallet

账户地址和私钥在这里：https://docs.zksync.io/zksync-era/tooling/local-setup/anvil-zksync-node#pre-configured-rich-wallets

```shell
cast wallet import zksyncKey --interactive
```

#### 部署合约到本地网络

需要注意：

- foundry-zksync 对 `forge script` 脚本部署支持的不太好，所以要用 `forge create` 来部署合约
- foundry-zksync 需要指定合约文件的路径及要部署的合约名称，例如 `src/Test.sol:Test`
- 需要加上 `--zksync` 以及 `--legacy` 参数

```shell
forge create src/SimpleStorage.sol:SimpleStorage --rpc-url $ZKSYNC_RPC_URL --account zksyncKey --zksync --legacy --broadcast
```

部署完成后会看到下面的信息

```shell
Deployer: 0xBC989fDe9e54cAd2aB4392Af6dF60f04873A033A
Deployed to: 0x9c1a3d7C98dBF89c7f5d167F2219C29c2fe775A7
Transaction hash: 0xf0322bbbdf608fa24f89a9a437196ee55e52be43eebd7124b4a1b3dfc9eff977
```

## 与合约交互

### 通过命令行交互

使用 `send` 调用需要修改链上数据的函数

```shell
cast send 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "store(int256)" 8 --rpc-url $LOCAL_RPC_URL --account defaultKey
```

使用 `call` 调用不修改链上数据的函数

```shell
cast call 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "retrieve()" --rpc-url $LOCAL_RPC_URL --account defaultKey
```



