// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract DeployConstants {

    uint256 internal constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 internal constant ETH_MAIN_NET_CHAIN_ID = 1;
    uint256 internal constant ANVIL_CHAIN_ID = 31173;

    uint256 internal constant DEFAULT_ENTRANCE_FEE = 1 ether;
    uint256 internal constant DEFAULT_INTERVAL = 30;
    uint256 internal constant DEFAULT_ENTRANCE_FEE = 1 ether;

    uint96 internal constant MOCK_BASE_FEE = 0.25 ether;
    uint96 internal constant MOCK_GAS_PRICE_LINK = 1e9;
    // LINK / ETH price
    int256 internal constant MOCK_WEI_PER_UINT_LINK = 4e15;
    address internal constant FOUNDRY_DEFAULT_SENDER = 0x0;
    uint256 internal constant DEFAULT_FUND_AMOUNT = 3 ether;

    address internal constant ETH_SEPOLIA_VRF_COORDINATOR_ADDRESS = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    address internal constant ETH_SEPOLIA_LINK_TOKEN_ADDRESS = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address internal constant ETH_SEPOLIA_GAS_LANE_ADDRESS = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    address internal constant ETH_MAIN_NET_VRF_COORDINATOR_ADDRESS = 0xD7f86b4b8Cae7D942340FF628F82735b7a20893a;
    address internal constant ETH_MAIN_NET_LINK_TOKEN_ADDRESS = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address internal constant ETH_MAIN_NET_GAS_LANE_ADDRESS = 0xc6bf2e7b88e5cfbb4946ff23af846494ae1f3c65270b79ee7876c9aa99d3d45f;


}
