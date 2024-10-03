// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract IfElse {
    //pure 表示该函数不会读取或修改合约的状态（即不会访问 storage 中的变量）。
    function foo(uint256 x) public pure returns (uint256){
        if(x < 10){
            return 0;
        }else if (x < 20 ){
            return 1;
        }else{
            return 2;
        }
    }
}