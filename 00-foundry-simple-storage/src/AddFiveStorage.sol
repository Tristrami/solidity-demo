// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {SimpleStorage} from "./SimpleStorage.sol";

contract AddFiveStorage is SimpleStorage {

    function store(int256 _number) public override {
        number = _number + 5;
    }

}
