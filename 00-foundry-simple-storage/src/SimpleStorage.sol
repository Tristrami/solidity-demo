// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract SimpleStorage {

    int256 public number;

    struct Person {
        string name;
        uint256 favoriteNumber;
    }

    Person[] public peopleArr;

    mapping(string => Person) public nameToPerson;

    function store(int256 _number) public virtual  {
        number = _number;
    }

    function retrieve() public view returns(int256) {
        return number;
    }

    function squared(int256 num) public pure returns(int256) {
        return num * num;
    }
    
    function addPersonToArr(string memory name, uint256 favoriteNumber) public {
        peopleArr.push(Person(name, favoriteNumber));
    }

    function addPersonToMap(string memory name, uint256 favoriteNumber) public {
        nameToPerson[name] = Person(name, favoriteNumber);
    }
}