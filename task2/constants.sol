// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Constants{
    //常量是不能修改的变量  可以节省gas
    address public constant MY_ADDRESS = 0x777788889999AaAAbBbbCcccddDdeeeEfFFfCcCc;
    uint256 public constant MY_UINT = 123;
}