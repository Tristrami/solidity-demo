// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// sepolia 0x614c0c164283Bf720efF157Cee0B9d55AFd709e0
contract LuluToken is ERC20 {

    uint256 private constant INITIAL_SUPPLY = 100 ether;

    constructor() ERC20("LuluToken", "MIAO") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

}

