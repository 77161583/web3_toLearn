// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Function {

    /*
        功能：这个函数返回多个值，包括 uint256 类型的数字、bool 类型的布尔值，以及另一个 uint256 类型的数字。
        返回值：(1, true, 2)，返回三个值，分别是 1，true 和 2。
        pure 关键字：表示该函数不会读取或修改合约的状态变量。
    */
    function returnMany() public pure returns (uint256, bool, uint256) {
        return (1, true, 2);
    }

    /*
        功能：这是与 returnMany() 类似的函数，但是返回值被命名为 x, b 和 y。
        命名返回值的优势：可以让返回值更具可读性，代码更清晰。
        返回值：仍然是 (1, true, 2)，但是可以更明确地知道每个值对应什么。
    */
    function named() public pure returns (uint256 x, bool b, uint256 y) {
        return (1, true, 2);
    }


    /*
        功能：这个函数与 named() 的功能相同，但通过直接赋值给命名的返回变量，避免了 return 语句。
        特点：在 Solidity 中，命名返回值的变量在函数体内是局部变量，因此可以直接对其进行赋值，最后返回这些值时可以省略 return 语句。 
    */
    function assigned() public pure returns (uint256 x, bool b, uint256 y) {
        x = 1;
        b = true;
        y = 2;
    }

    /*
        解构赋值：通过调用 returnMany() 函数来接收多个返回值，并通过解构方式将其赋值给多个变量 i, b, 和 j。
        跳过值：可以在解构赋值时跳过不需要的值，例子中 x 和 y 分别接收 4 和 6，而 5 被跳过。
        返回值：函数返回 (1, true, 2, 4, 6)，其中 1, true, 2 是从 returnMany() 得到的，4 和 6 是解构赋值的结果。
    */
    function destructuringAssignments() public pure returns (uint256, bool, uint256, uint256, uint256){
        (uint256 i, bool b, uint256 j) = returnMany();

        // Values can be left out.
        (uint256 x,, uint256 y) = (4, 5, 6);

        return (i, b, j, x, y);
    }

    //功能：该函数接受一个 uint256 类型的数组作为输入参数。虽然函数体内没有具体的操作，但展示了如何使用数组作为输入。
    //memory 关键字：表示数组 _arr 只在函数调用期间存储在内存中，调用结束后被销毁。
    function arrayInput(uint256[] memory _arr) public {}


    /*
        状态变量 arr：一个 uint256 类型的动态数组，存储在合约的 storage 中，公开可访问。
        arrayOutput()：返回 arr 数组的内容。返回的数组使用 memory 关键字，因为 Solidity 不能直接返回 storage 数组。
        特点：数组的输入和输出可以直接用 memory 来处理，适合在函数之间传递数据，但这些数据并不会永久存储在区块链上。
    */
    uint256[] public arr;
    function arrayOutput() public view returns (uint256[] memory) {
        return arr;
    }


    /*
        功能：这是一个有多个参数的函数，接受 uint256 类型的三个值 x, y, z，一个 address 类型的地址 a，一个 bool 值 b，以及一个 string 类型的字符串 c。
        返回值：函数返回一个 uint256 值（这里未实现具体逻辑）。
    */
    //带有多个参数的函数
    function someFuncWithManyInputs(
        uint256 x,
        uint256 y,
        uint256 z,
        address a,
        bool b,
        string memory c
    ) public pure returns (uint256) {}

    /*
        功能：调用 someFuncWithManyInputs 函数，并通过位置传递参数。这里传递的值依次为 1, 2, 3, address(0), true, "c"。
        特点：参数按顺序排列传递，依次与函数定义中的参数位置匹配。
    */
    //通过位置传递参数调用函数
    function callFunc() external pure returns (uint256) {
        return someFuncWithManyInputs(1, 2, 3, address(0), true, "c");
    }

    /*
        功能：通过键值对的方式传递参数。这种方式允许参数按任意顺序传递，只要对应的键名正确。
        特点：使用键值对时，可以灵活传递参数，而不需要考虑顺序。每个参数都通过键名匹配函数定义中的参数。
    */
    function callFuncWithKeyValue() external pure returns (uint256) {
        return someFuncWithManyInputs({
            a: address(0),
            b: true,
            c: "c",
            x: 1,
            y: 2,
            z: 3
        });
    }
}

/*
多返回值：Solidity 支持函数返回多个值，并且可以通过命名返回值、赋值给命名变量等方式进行简化操作。
解构赋值：通过解构赋值，可以从一个返回多个值的函数中提取所需的值，还可以跳过不需要的值。
数组处理：Solidity 函数可以使用数组作为参数传递，也可以返回数组，通常需要通过 memory 关键字来指定数据位置。
参数传递：函数调用时，可以通过位置传递参数，也可以使用键值对传递，这种方式可以增加代码的可读性和灵活性，尤其是在函数有很多参数时。
*/