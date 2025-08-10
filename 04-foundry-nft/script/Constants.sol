// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Constants {

    // tokenUri 指向的是 json 格式的 metadata 文件，不是图片
    string public constant LULU_NFT_TOKEN_URI = "ipfs://QmVwRBznXtw3noqXoCz7pko2itpWhd5mAptAmf4EZbu8eL";
    // 存放 svg 的目录
    string public constant WEATHER_SVG_BASE_PATH = "assets/weathernft/image";
    // nft svg 的 uri 前缀
    string public constant SVG_BASE_URI = "data:image/svg+xml;base64,";
    // nft tokenUri 的前缀
    string public constant TOKEN_BASE_URI = "data:application/json;base64,";
    // sunny svg 文件名称
    string public constant SUNNY_SVG_FILE_NAME = "sunny";
    // sunny svg 文件名称
    string public constant RAINY_SVG_FILE_NAME = "rainy";
}
