// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {WeatherNft} from "src/WeatherNft.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Constants} from "script/Constants.sol";

contract DeployWeatherNft is Script, Constants {

    function run() external {
        vm.startBroadcast();
        deploy(
            createTokenUri(SUNNY_SVG_FILE_NAME),
            createTokenUri(RAINY_SVG_FILE_NAME)
        );
        vm.stopBroadcast();
    }

    function deploy(string memory sunnyTokenUri, string memory rainyTokenUri) public returns (WeatherNft) {
        return new WeatherNft(sunnyTokenUri, rainyTokenUri);
    }

    function createTokenUri(string memory svgName) private returns (string memory) {

        string memory tokenUriKey = "tokenUri";
        string memory attributeKey = "attribute";
        string memory svgBase64 = Base64.encode(abi.encodePacked(readSvg(svgName)));
        string memory svgUri = string.concat(SVG_BASE_URI, svgBase64);
        // attribute 对象
        vm.serializeString(attributeKey, "trait_type", "weather");
        string memory attribute = vm.serializeString(attributeKey, "value", "100");
        string[] memory attributes = new string[](1);
        attributes[0] = attribute;
        // tokenUri 对象
        vm.serializeString(tokenUriKey, "name", "Weather");
        vm.serializeString(tokenUriKey, "description", "Weather NFT");
        vm.serializeString(tokenUriKey, "image", svgUri);
        string memory tokenUriJson = vm.serializeString(tokenUriKey, "attributes", attributes);
        return string.concat(TOKEN_BASE_URI, Base64.encode(abi.encodePacked(tokenUriJson)));
    }

    function readSvg(string memory svgName) private returns (string memory) {
        string memory path = string.concat(WEATHER_SVG_BASE_PATH, svgName, ".svg");
        return vm.readFile(path);
    }
}
