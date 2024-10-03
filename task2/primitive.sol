// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Primitive {
    //boo 是一个布尔类型的变量，初始化为 true。
    bool public boo = true;

    // uint 表示无符号整数，意味着非负整数。  
    uint8 public u8 = 1; // uint8 的范围是 0 到 255  
    uint256 public u256 = 456; // uint256 的范围从 0 到 2^256 - 1  
    uint256 public u = 123; // uint 是 uint256 的别名

    // int 类型允许负数。  
    int8 public i8 = -1; // int8 的范围是 -128 到 127  
    int256 public i256 = 456; // int256 的范围是 -2^255 到 2^255 - 1  
    int256 public i = -123; // int 是 int256 的别名

    //整数的最小值和最大值
    int256 public minInt = type(int256).min; // int256 的最小值  
    int256 public maxInt = type(int256).max; // int256 的最大值

    //地址类型
    address public addr = 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c; // Ethereum 地址

    /*  
        在 Solidity 中，字节类型表示字节序列。Solidity 提供两种字节类型：  
        - 固定大小的字节数组  
        - 动态大小的字节数组  
        在 Solidity 中，bytes 表示一个动态字节数组，是 byte[] 的简写。  
    */  
    bytes1 a = 0xb5; // 代表一个固定大小、包含一个字节的值 [10110101]  
    bytes1 b = 0x56; // 代表一个固定大小、包含一个字节的值 [01010110]


    //默认值：  未赋值的变量具有默认值  
    bool public defaultBoo; // 默认值为 false  
    uint256 public defaultUint; // 默认值为 0  
    int256 public defaultInt; // 默认值为 0  
    address public defaultAddr; // 默认值为 0x0000000000000000000000000000000000000000

}