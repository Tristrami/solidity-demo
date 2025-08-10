// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
Contract elements should be laid out in the following order:
Pragma statements
Import statements
Events
Errors
Interfaces
Libraries
Contacts

Inside each contract, library or interface, use the following order:
Type declarations
State variables
Events
Errors
Modifiers
Functions
 */

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// 0x5FbDB2315678afecb367f032d93F642f64180aa3
contract LuluNft is ERC721URIStorage {

    uint256 private s_tokenIdCounter;

    event NftMinted(uint256 indexed tokenId, string indexed tokenUri);

    constructor() ERC721("Lulu", "Lulu") {}

    function mintNft(string memory tokenUri) public returns (uint256) {
        uint256 tokenId = s_tokenIdCounter;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenUri);
        s_tokenIdCounter++;
        emit NftMinted(tokenId, tokenUri);
        return tokenId;
    }

}
