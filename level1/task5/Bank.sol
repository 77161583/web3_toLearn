// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Bank {
    //声明了合约的创建者地址
    address public immutable owner;

    //两个事件 Deposit 用于记录存款信息，Withdraw 用于记录提款信息。
    event Deposit(address _ads, uint256 amount);
    event Withdraw(uint256 amount);

    //定义一个接收 Ether 的接收函数。当合约收到 Ether 时，会触发 Deposit 事件。
    receive() external payable { 
        emit Deposit(msg.sender,msg.value);
    }

    //构造函数，当合约部署时执行。它将合约的创建者地址设为 owner
    constructor() payable{
        owner = msg.sender;
    }

    //提款
    function withdraw() external {
        require(msg.sender == owner,"Not owner");
        emit Withdraw(address(this).balance);
        //selfdestruct 销毁合约并将剩余余额发送给拥有者。
        selfdestruct(payable(msg.sender));
    }
    //查询余额函数
    function getBalance() external view returns (uint256){
        return address(this).balance;
    }
}