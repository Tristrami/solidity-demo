// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// 0x5FC8d32690cc91D4c39d9d3abcBD16989F875707
contract WeatherNft is ERC721URIStorage {

    enum Weather { SUNNY, RAINY }

    mapping(Weather => string tokenUri) private weatherToTokenUri;
    mapping(uint256 tokenId => Weather) private tokenIdToWeather;
    uint256 private tokenIdCounter;

    event NftMinted(uint256 indexed tokenId, string indexed tokenUri);

    constructor(
        string memory sunnyTokenUri,
        string memory rainyTokenUri
    ) ERC721("Weather", "Weather") {
        weatherToTokenUri[Weather.SUNNY] = sunnyTokenUri;
        weatherToTokenUri[Weather.RAINY] = rainyTokenUri;
    }

    function mintNft() public returns (uint256) {
        uint256 tokenId = tokenIdCounter;
        string memory initialTokenUri = weatherToTokenUri[Weather.SUNNY];
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, initialTokenUri);
        tokenIdToWeather[tokenId] = Weather.SUNNY;
        emit NftMinted(tokenId, initialTokenUri);
        return tokenId;
    }

    function flipWeather(uint256 tokenId) public {
        _requireOwned(tokenId);
        Weather newWeather = tokenIdToWeather[tokenId] == Weather.SUNNY ? Weather.RAINY : Weather.SUNNY;
        tokenIdToWeather[tokenId] = newWeather;
        _setTokenURI(tokenId, weatherToTokenUri[newWeather]);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        return weatherToTokenUri[tokenIdToWeather[tokenId]];
    }

}
