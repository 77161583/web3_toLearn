// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Event {
    /*
        Log 事件：
            Log(address indexed sender, string message)：该事件声明了两个参数：
            address indexed sender：记录触发事件的发送者地址，indexed 关键字表示这个参数是可索引的，允许外部工具（例如事件监听器或区块链浏览器）根据发送者地址过滤事件。
            string message：表示一条日志消息。
            indexed 参数：最多可以为事件声明三个 indexed 参数。indexed 参数使得事件可以被更高效地过滤和搜索。例如，通过索引，可以直接根据 sender 来查找某个地址触发的事件。
        AnotherLog 事件：
            该事件没有参数，仅仅是为了展示如何声明一个没有参数的事件。
    */
    event Log(address indexed sender, string message);
    event AnotherLog();


    /*
        test 函数触发了多个事件，向区块链日志中写入信息。
        emit 关键字：用于触发事件。每当调用 emit 时，事件就会记录在区块链的交易日志中。
        具体触发的事件：
        emit Log(msg.sender, "Hello World!");：
        触发 Log 事件，记录调用合约的发送者地址（msg.sender）和消息 "Hello World!"。
        emit Log(msg.sender, "Hello EVM!");：
        再次触发 Log 事件，记录发送者地址和消息 "Hello EVM!"。
        emit AnotherLog();：
        触发 AnotherLog 事件（没有参数）。
    */
    function test() public {
        emit Log(msg.sender, "Hello World!");
        emit Log(msg.sender, "Hello EVM!");
        emit AnotherLog();
    }
    /*
        . 事件的作用
        区块链上的日志记录：事件不会直接修改链上的状态，但它们会将一些关键信息记录在交易日志中。事件日志无法被智能合约访问（即日志对智能合约不可见），但外部工具（如前端应用、区块链浏览器等）可以通过监听这些事件获取信息。
        使用 indexed 参数过滤：由于 Log 事件的 sender 参数被声明为 indexed，因此可以通过外部工具筛选出特定地址触发的事件。例如，你可以查询某个特定用户发送的所有事件。
    */
}

/*
总结
事件 是 Solidity 中用于记录特定操作或状态变化的一种机制，外部系统可以通过监听事件来追踪合约的行为。
emit 关键字用于触发事件，将其写入区块链的日志中。
indexed 参数允许外部系统根据事件的参数高效地过滤和搜索事件日志。
通过这种方式，开发者和用户可以在不修改合约状态的情况下，追踪合约的执行过程
*/