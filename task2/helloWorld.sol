// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract HelloWorld{
    string public greet = "Hello world!";

    function getStr() public view returns (string memory){
        return greet;
    }
}