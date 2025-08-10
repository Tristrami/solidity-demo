// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DeployLuluNft} from "script/DeployLuluNft.s.sol";
import {MintLuluNft} from "script/Interaction.s.sol";
import {LuluNft} from "src/LuluNft.sol";
import {Test, console2} from "forge-std/Test.sol";
import {Constants} from "script/Constants.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract LuluNftTest is Test, Constants {

    DeployLuluNft private deployer;
    MintLuluNft private mintNft;
    LuluNft private luluNft;
    address private user;

    constructor() {
        deployer = new DeployLuluNft();
        mintNft = new MintLuluNft();
        user = makeAddr("user");
    }

    function setUp() external {
        luluNft = deployer.deploy();
    }

    function testMetaData() public {
        // 字符串比较，需要编码为二进制之后，比较哈希值
        assertEq(
            keccak256(abi.encodePacked(luluNft.name())),
            keccak256(abi.encodePacked("Lulu"))
        );
        assertEq(
            keccak256(abi.encodePacked(luluNft.symbol())),
            keccak256(abi.encodePacked("Lulu"))
        );
    }

    function testMintNft() public {
        vm.prank(user);
        uint256 tokenId = luluNft.mintNft(LULU_NFT_TOKEN_URI);
        assertEq(luluNft.tokenURI(tokenId), LULU_NFT_TOKEN_URI);
        assertEq(luluNft.balanceOf(user), 1);
    }

    function testJson() public {
        string memory tokenUriKey = "tokenUri";
        string memory attributeKey = "attribute";
        string memory svgBase64 = Base64.encode(abi.encodePacked(readSvg(SUNNY_SVG_FILE_NAME)));
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
        string memory tokenUri = vm.serializeString(tokenUriKey, "attributes", attributes);
        console2.log(tokenUri);
    }

    function readSvg(string memory svgName) private returns (string memory) {
        string memory path = string.concat(WEATHER_SVG_BASE_PATH, svgName, ".svg");
        return vm.readFile(path);
    }

    function testEncode() public {
        string memory s = "hello";
        assertEq(bytes(s), abi.encode(s));
    }
}