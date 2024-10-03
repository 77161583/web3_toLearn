// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Variable {
    /*
        Local
            在函数中声明
            不存储在区块链上
        
        State
            在函数外声明
            存储在区块链上
    
        Global
            提供关于区块链的信息
    */

    // 存储在区块链上的变量
    string public test = "aaaaa";
    uint256 public num = 123;

    function doSomething() public view {  
        // 本地变量，不会保存在区块链上  
        uint256 i = 456;  
        // 全局变量  
        uint256 timestamp = block.timestamp;  
        address sender = msg.sender;
    }  
}