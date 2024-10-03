// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Name {
    //写入和更新状态变量，需要发送交易
    //读取状态变量，无需任何交易费用

    //用于存储数字的状态变量
    uint256 public num;

    //您需要发送一个事务来写入状态变量。
    function set(uint256 _num) public {
        num = _num;
    }

    //您可以在不发送事务的情况下读取变量状态
    function get() public view returns (uint256){
        return num;
    }
    
}