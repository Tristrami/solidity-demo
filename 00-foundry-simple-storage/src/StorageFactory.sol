// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {SimpleStorage} from "./SimpleStorage.sol";

contract StorageFactory {

    SimpleStorage[] public contracts;

    function create() public {
        contracts.push(new SimpleStorage());
    }

    function store(uint256 _index, int256 _number) public {
        assert(_index < contracts.length);
        SimpleStorage simpleStorage = SimpleStorage(contracts[_index]);
        simpleStorage.store(_number);
    }

    function retrieve(uint256 _index) public view returns(int256) {
        assert(_index < contracts.length);
        SimpleStorage simpleStorage = SimpleStorage(contracts[_index]);
        return simpleStorage.retrieve();
    }

}
