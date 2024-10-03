// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract DataLocations {
    /*
        storage变量是一个状态变量（存储在区块链上）
        memory变量位于内存中，并且在调用函数时存在
        calldata包含函数参数的特殊数据位置
    */


    /*
        arr：一个 uint256 类型的动态数组，存储在 storage 中（区块链上）。
        map：一个映射，将 uint256 映射到 address，也存储在 storage 中。
        MyStruct：定义了一个名为 MyStruct 的结构体，包含一个 uint256 类型的字段 foo。
        myStructs：一个映射，将 uint256 映射到 MyStruct 结构体的实例，同样存储在 storage 中。
    */
    uint256[] public arr;
    mapping(uint256 => address) map;

    struct MyStruct {
        uint256 foo;
    }

    mapping(uint256 => MyStruct) myStructs;

    //如何操作和传递 storage 和 memory 变量。
    function f() public {
        // 这里将状态变量 arr、map 和 myStructs[1] 作为 storage 引用传递给内部函数 _f。_f 函数接收这些变量并在其内部操作。
        _f(arr, map, myStructs[1]);

        // 使用 storage 关键字从映射 myStructs 中获取 MyStruct 结构体的引用。这个引用指向区块链上的实际存储数据。
        MyStruct storage myStruct = myStructs[1];
        // 使用 memory 关键字创建一个临时的 MyStruct 结构体，这个结构体只存在于当前函数调用期间，并且不会被写入区块链。
        MyStruct memory myMemStruct = MyStruct(0);
    }

    //_f 是一个内部函数，接受三种不同的 storage 引用：数组 _arr、映射 _map 和结构体 _myStruct。
    /*
        _arr 是一个 storage 类型的数组引用。
        _map 是一个 storage 类型的映射引用。
        _myStruct 是一个 storage 类型的结构体引用。
    */
    function _f(
        uint256[] storage _arr,
        mapping(uint256 => address) storage _map,
        MyStruct storage _myStruct
    ) internal {
        // do something with storage variables
    }

    /*
        功能：g 函数接受一个 memory 数组作为参数，并返回一个 memory 数组。
        memory 数据位置：_arr 是在内存中创建的临时数组，它仅在函数执行期间存在，不会被永久存储在区块链上。
        用途：可以对 memory 数组进行一些临时的计算或操作，并将其结果返回。
    */
    function g(uint256[] memory _arr) public returns (uint256[] memory) {
        // do something with memory array
    }

    /*
        功能：h 函数接受一个 calldata 数组作为参数。calldata 是只读的，它表示函数调用时传入的数据，适用于函数参数的传递。
        calldata 数据位置：calldata 用于外部调用函数时传入的参数数据，效率较高且不可修改，因此常用于外部函数的参数传递。
    */
    function h(uint256[] calldata _arr) external {
        // do something with calldata array
    }



}