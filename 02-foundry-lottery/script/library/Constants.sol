// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library Constants {

    /* Chain ID */
    uint256 internal constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 internal constant ETH_MAIN_NET_CHAIN_ID = 1;
    uint256 internal constant ANVIL_CHAIN_ID = 31337;

    /* Raffle 配置 */
    uint256 internal constant DEFAULT_ENTRANCE_FEE = 0.01 ether;
    uint256 internal constant DEFAULT_INTERVAL = 30;

    /* VRFCoordinatorV2_5Mock 配置 */
    uint96 internal constant MOCK_BASE_FEE = 0.25 ether;
    uint96 internal constant MOCK_GAS_PRICE_LINK = 1e9;
    // LINK / ETH price
    int256 internal constant MOCK_WEI_PER_UINT_LINK = 4e15;

    /* 测试配置 */
    uint256 internal constant DEFAULT_LOCAL_NET_FUND_AMOUNT = 100 ether;
    uint256 internal constant DEFAULT_TEST_NET_FUND_AMOUNT = 0.1 ether;
    // Anvil 配置
    address internal constant FOUNDRY_DEFAULT_SENDER = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
    // Sepolia 配置
    address internal constant ETH_SEPOLIA_VRF_COORDINATOR_ADDRESS = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    address internal constant ETH_SEPOLIA_LINK_TOKEN_ADDRESS = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    bytes32 internal constant ETH_SEPOLIA_GAS_LANE = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint256 internal constant ETH_SEPOLIA_SUBSCRIPTION_ID = 81063132526323911615763813490115581616074095923090379620076393665856128224994;
    address internal constant ETH_SEPOLIA_DEFAULT_ACCOUNT = 0x37CA3984F65bEB9400669c94faeEFaf1FC649964;
    // Mainnet 配置
    address internal constant ETH_MAIN_NET_VRF_COORDINATOR_ADDRESS = 0xD7f86b4b8Cae7D942340FF628F82735b7a20893a;
    address internal constant ETH_MAIN_NET_LINK_TOKEN_ADDRESS = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    bytes32 internal constant ETH_MAIN_NET_GAS_LANE = 0xc6bf2e7b88e5cfbb4946ff23af846494ae1f3c65270b79ee7876c9aa99d3d45f;
    uint256 internal constant ETH_MAIN_NET_SUBSCRIPTION_ID = 0;
    address internal constant ETH_MAIN_NET_DEFAULT_ACCOUNT = 0x37CA3984F65bEB9400669c94faeEFaf1FC649964;
}
