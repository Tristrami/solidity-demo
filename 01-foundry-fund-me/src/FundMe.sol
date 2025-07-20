// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotEnoughEth();
error FundMe__NotContractOwner();

/**
 * 这个合约的主要功能：
 * 1. 可以接受其他地方发送过来的 ETH，并记录 funders
 * 2. 合约的拥有者（部署者）可以提现
 */
contract FundMe {

    /**
     * 为 uint256 数据类型添加 PriceConverter library
     */
    using PriceConverter for uint256;

    /**
     * 最小 fund 的美元，精度 18 位，constant 类型变量在编译阶段初始化，硬编码到字节码中
     */
    uint256 private constant MINIMUM_USD = 1e18;

    /**
     * immutable 类型变量需要在合约部署（创建）阶段初始化
     */
    address private immutable i_owner;

    /**
     * mapping 会自动初始化，无法遍历，无法作为函数参数使用
     */
    mapping(address => uint256) private s_funderToAmountFunded;

    /**
     * 0.8.x 后的版本数组会自动初始化
     */
    address[] private s_funders;

    /**
     * eth/usd price feed
     */
    AggregatorV3Interface private s_priceFeed;

      /**
     * 自定义函数修饰符
     */
    modifier OnlyOwner {
        require(msg.sender == i_owner, FundMe__NotContractOwner());
        // _ 代表执行原函数逻辑
        _;
    }

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        // getEthAmountInUsd 会自动将 msg.value 作为第一个参数传入函数中
        require(msg.value.getEthAmountInUsd(s_priceFeed) >= MINIMUM_USD, FundMe__NotEnoughEth());
        s_funderToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() public OnlyOwner {
        // 避免频繁读取 storage 变量
        uint256 length = s_funders.length;
        for(uint256 i = 0; i < length; i++) {
            s_funderToAmountFunded[s_funders[i]] = 0;
        }
        // 重新初始化数组，初始长度设为 0
        s_funders = new address[](0);
        // 向 owner 账户发送 ETH
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getAmountFunded(address funderAddress) external view returns (uint256) {
        return s_funderToAmountFunded[funderAddress];
    }

    /**
     * solidity 中的默认函数 receive 和 fallback，当外部地址发送 ETH 但没有指定调用的函数时，会调用默认函数
     * is msg.data empty?
     *          /   \
     *         yes  no
     *         /     \
     *    receive()?  fallback()
     *     /   \
     *   yes   no
     *  /        \
     *receive()  fallback()
     */
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}