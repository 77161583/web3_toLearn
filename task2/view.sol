// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

//view 和 pure 是函数修饰符，表示该函数对合约的状态变量有不同程度的访问限制
contract ViewAndPure {
    //定义了一个名为 x 的 uint256 类型的状态变量，初始值为 1。这是一个公开的变量，外部可以通过自动生成的 getter 函数读取它的值
    uint256 public x = 1;

    /*
        功能：addToX 函数接受一个 uint256 类型的参数 y，返回 x + y 的值。
        view 修饰符：表示该函数承诺不修改合约的状态。它可以读取状态变量（如 x），但不能对其进行修改。
        返回值：返回 x + y 的值。

    */
    function addToX(uint256 y) public view returns (uint256) {
        return x + y;
    }

    /*
        功能：add 函数接受两个 uint256 类型的参数 i 和 j，返回 i + j 的结果。
        pure 修饰符：表示该函数承诺既不读取也不修改合约的状态。它只能在函数内部操作传入的参数，不能访问合约中的状态变量。
        返回值：返回 i + j 的值。
    */ 
    function add(uint256 i, uint256 j) public pure returns (uint256) {
        return i + j;
    }
}

/*
view 函数：可以读取合约的状态变量，但不能修改它们。在这个例子中，addToX 函数读取了状态变量 x 并与传入的参数 y 相加。
pure 函数：既不能读取状态变量，也不能修改它们。它只能操作传入的参数。在这个例子中，add 函数只是简单地将两个传入的参数 i 和 j 相加，并返回结果。
这两种修饰符用于确保函数的行为符合约定，并优化合约的性能和安全性。
*/