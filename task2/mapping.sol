// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Mapping  {
    //从地址映射到uint
    mapping(address => uint256) public myMap;

    //映射总是返回一个值。
    //如果从未设置该值，它将返回默认值。
    function get(address _addr) public view returns (uint256){
        return myMap[_addr];
    }   

    //更新此地址的值
    function set(address _addr, uint256 _i) public {
        myMap[_addr] = _i; 
    }

    //将该值重置为默认值。
    function remove(address _addr) public {
        delete myMap[_addr];
    }
}

contract NestedMapping {
    //嵌套映射（从地址映射到另一个映射）
    mapping(address => mapping(uint256 => bool)) public nested;

    function get(address _addr1, uint256 _i) public view returns (bool) {
        //您可以从嵌套映射中获取值
        //即使它没有初始化
        return nested[_addr1][_i];
    }

    function set(address _addr1, uint256 _i, bool _boo) public {
        nested[_addr1][_i] = _boo;
    }

    function remove(address _addr1, uint256 _i) public {
        delete nested[_addr1][_i];
    }
}