// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Erroe {
    function testRequire(uint256 _i) public pure {
        //require 语句：用于检查条件是否为 true。如果条件为 false，会抛出异常，并回滚交易。
        require(_i > 10, "Input must be greater than 10");
    }


    /*
        功能：testRevert 函数的行为与 testRequire 相同，但使用 revert 语句来抛出异常。
        revert 语句：用于手动回滚交易，并且可以附加错误消息。它特别适用于处理复杂条件的场景。
        用途：当条件检查较复杂时，可以使用 revert，因为它提供了更灵活的错误处理机制。
        特点：revert 可以手动触发错误，适合在条件判断之后回滚操作。
    */
    function testRevert(uint256 _i) public pure {
        if (_i <= 10) {
            revert("Input must be greater than 10");
        }
    }


    uint256 public num;
    /*
        assert 语句：testAssert 函数使用 assert 语句检查内部条件是否成立。这里 assert 检查 num 是否总是等于 0。
        assert 用途：assert 用于检测程序中的内部错误或不变量。它在发生不可预期的错误时抛出异常，并消耗所有剩余的 Gas。
        特点：assert 应该只用于验证那些永远不应该失败的条件（如内部逻辑错误）。assert 失败通常意味着存在严重的漏洞或错误。
    */
    function testAssert() public view {
        assert(num == 0);
    }

    /*
        自定义错误 InsufficientBalance：定义了一个自定义错误 InsufficientBalance，它包含两个参数 balance 和 withdrawAmount。
        自定义错误的用途：自定义错误是 Solidity 0.8.4 引入的一种更节省 Gas 的错误处理方式，尤其适用于错误信息较复杂的情况。与字符串错误消息相比，自定义错误在触发时可以节省更多的 Gas。
        testCustomError 函数：
        该函数首先获取当前合约的余额 bal，然后检查是否可以进行指定的 _withdrawAmount 提现操作。
        如果余额不足，则使用自定义错误 InsufficientBalance 来回滚交易，并附带当前余额和请求的提现金额。
    
    */
    error InsufficientBalance(uint256 balance, uint256 withdrawAmount);

    function testCustomError(uint256 _withdrawAmount) public view {
        uint256 bal = address(this).balance;
        if (bal < _withdrawAmount) {
            revert InsufficientBalance({
                balance: bal,
                withdrawAmount: _withdrawAmount
            });
        }
    }
}
/*
总结：
require：用于验证输入条件或调用前的状态，常用于外部条件的检查（如输入参数验证）。
revert：手动触发错误回滚，适合处理复杂的条件。
assert：用于检测内部错误或不变量，一旦失败会消耗所有剩余的 Gas，适合用来检查永远不应该发生的错误。
自定义错误：自定义错误提供了一种节省 Gas 的方式来触发带参数的错误回滚，适用于需要传递错误上下文的情况。
*/




/*
定义了一个简单的 Account 合约，用于管理账户的存款和取款操作。
它通过 deposit 和 withdraw 函数分别处理存款和取款操作，同时使用 require 和 assert 语句来确保操作的安全性，防止溢出（Overflow）和下溢（Underflow）等问题。
*/
contract Account {
    //balance：这是账户的余额，uint256 类型。它公开可访问，意味着合约外部可以通过自动生成的 getter 方法来读取账户的当前余额。
    //MAX_UINT：这是 uint256 类型的最大值，定义为 2^256 - 1。这是 Solidity 中无符号整数（uint256）能够表示的最大值。这个常量没有实际在函数中使用，但可以用于防止溢出时的比较或限制。
    uint256 public balance;
    uint256 public constant MAX_UINT = 2 ** 256 - 1;

    //deposit 函数允许用户存款，将指定金额 _amount 添加到当前账户余额中。
    function deposit(uint256 _amount) public {
        uint256 oldBalance = balance;
        uint256 newBalance = balance + _amount;

        // 检查溢出：通过 require 检查是否发生溢出（Overflow）。如果 newBalance 小于 oldBalance，则发生了溢出，触发异常 "Overflow" 并回滚交易
        require(newBalance >= oldBalance, "Overflow");

        //更新余额：如果检查通过，将新余额 newBalance 赋值给 balance。
        balance = newBalance;

        //断言余额更新：使用 assert 确保新的余额 balance 一定大于或等于旧余额 oldBalance。如果条件不满足，说明代码中存在严重错误。
        assert(balance >= oldBalance);
    }

    //允许用户取款，从当前账户余额中减去指定金额 _amount。
    function withdraw(uint256 _amount) public {
        uint256 oldBalance = balance;

        //通过 require 检查余额是否足够支付取款金额。如果当前余额 balance 小于 _amount，则触发异常 "Underflow"，防止下溢（Underflow）。
        //条件为false的时候触发
        require(balance >= _amount, "Underflow");

        //再次检查下溢：即使前面有 require 检查，代码还是增加了一个 if 判断，手动调用 revert 以确保万无一失。这是双重检查机制。
        if (balance < _amount) {
            revert("Underflow");
        }

        balance -= _amount;

        assert(balance <= oldBalance);
    }
}