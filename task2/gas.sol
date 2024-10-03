// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Gas {
    uint256 public i = 0;

    //用完您发送的所有气体会导致您的交易失败。
    //状态更改将撤消。
    //已消耗的汽油不予退还。
    function forever() public {
        //在这里，我们运行一个循环，直到所有的气体都用完
        //交易失败
        while (true){
            i +=1;
        }
    }
        
}