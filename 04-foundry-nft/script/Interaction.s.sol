 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {LuluNft} from "src/LuluNft.sol";
import {WeatherNft} from "src/WeatherNft.sol";
import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {Constants} from "script/Constants.sol";

contract MintLuluNft is Script, Constants {

    function run() external {
        address luluNftAddress = DevOpsTools.get_most_recent_deployment("LuluNft", block.chainid);
        vm.startBroadcast();
        mintLuluNft(luluNftAddress, LULU_NFT_TOKEN_URI);
        vm.stopBroadcast();
    }

    function mintLuluNft(address luluNftAddress, string memory tokenUri) public returns (uint256) {
        return LuluNft(luluNftAddress).mintNft(tokenUri);
    }
}

contract MintWeatherNft is Script {

    function run() external {
        vm.startBroadcast();
        address weatherNftAddress = DevOpsTools.get_most_recent_deployment("WeatherNft", block.chainid);
        mintWeatherNft(weatherNftAddress);
        vm.stopBroadcast();
    }

    function mintWeatherNft(address weatherNftAddress) public returns (uint256) {
        return WeatherNft(weatherNftAddress).mintNft();
    }
}

 contract FlipWeather is Script {

     function run() external {
         vm.startBroadcast();
         address weatherNftAddress = DevOpsTools.get_most_recent_deployment("WeatherNft", block.chainid);
         flipWeather(weatherNftAddress, 0);
         vm.stopBroadcast();
     }

     function flipWeather(address weatherNftAddress, uint256 tokenId) public {
         WeatherNft(weatherNftAddress).flipWeather(tokenId);
     }
 }
