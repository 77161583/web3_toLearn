// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Counter{
    uint256 public count;

    //初始化
    function init_count(uint256 _value) public {
        count = _value;
    }

    function get() public view returns (uint256){
        return count;
    }

    function inc () public {
        count += 1;
    }

    function dec() public {
        if(count == 0){
            revert("this count is zero!");
        }
        count -= 1;
    }
}