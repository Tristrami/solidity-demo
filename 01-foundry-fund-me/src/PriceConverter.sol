// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * library 相当于工具类，可以用 using 关键字让某个数据类型增加这个 library 中的函数，
 * 这些函数需要是 internal
 */
library PriceConverter {

    function getEthPrice(AggregatorV3Interface ethPriceFeed) internal view returns(uint256) {
        // 2784 10572900，总共 8 位小数
        (, int256 answer, , ,) = ethPriceFeed.latestRoundData();
        uint256 price = uint256(answer);
        // 小数位数
        uint8 decimals = ethPriceFeed.decimals();
        // 转换成 18 位小数，因为最小单位 wei 的精度为 18 位
        if (decimals < 18) {
            price = uint256(price) * (10 ** (18 - decimals));
        }
        return price;
    }

    function getEthAmountInUsd(uint256 ethAmount, AggregatorV3Interface ethPriceFeed) internal view returns(uint256) {
        // 两个用整数表示的 18 位小数的浮点数，相乘后总共有 36 位小数，要去掉 18 位
        return (getEthPrice(ethPriceFeed) * ethAmount) / 1e18;
    }
}