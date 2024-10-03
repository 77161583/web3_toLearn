// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Immutable {
    //不可变变量就像常量。不可变变量的值可以在构造函数内设置，但之后不能修改。
    address public immutable MY_ADDRESS;
    uint256 public immutable MY_UINT;

    constructor(uint256 _myUint){
        MY_ADDRESS = msg.sender;
        MY_UINT = _myUint;
    }
    
}