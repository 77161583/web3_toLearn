// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract EtherWallet  {
    address payable public immutable owner;  //合约的所有者地址 payable 关键字表示该地址可以接收以太币
    event Log(string funName, address from,uint256 value, bytes data); //在接收以太币时会被触发，记录调用的函数名、发送者地址、转账金额和附加数据。
    //合约创建时，设置合约的所有者为部署合约的地址。
    constructor(){
        owner = payable (msg.sender);
    }
    //用于接收以太币。当合约收到以太币时，会触发这个函数，并记录事件。
    receive() external payable { 
        emit Log("receive",msg.sender,msg.value,"");
    }
    //允许合约所有者提取固定金额（100 wei）的以太币。
    //使用 require 检查调用者是否为合约所有者。
    //transfer(100) 将100 wei 转移给调用者。
    function withdraw1() external {
        require(msg.sender == owner,"Not owner");
        payable (msg.sender).transfer(100);
    }
    //这个函数允许合约所有者提取固定金额（200 wei）的以太币。
    // 使用 send 方法进行转账，返回一个布尔值表示是否成功。若失败，触发 require 返回错误信息。
    function withdraw2() external {
        require(msg.sender == owner,"Not owner");
        bool success = payable (msg.sender).send(200);
        require(success,"Send Failed");
    }
    //这个函数允许合约所有者提取合约中的所有余额。
    //使用 call 方法发送以太币，这是一种更灵活的转账方式。该方法可以发送任意数量的以太币，并可以携带额外数据。
    //
    function withdraw3() external {
        require(msg.sender == owner,"Not owner");
        (bool success,) = msg.sender.call{value:address(this).balance}("");
        require(success,"Call Failed");
    }
    //获取余额函数
    function getBalance() external view returns (uint256){
        return address(this).balance;
    }
}
/*
总结：
withdraw1: 提取固定金额（100 wei），使用 transfer 方法。
withdraw2: 提取固定金额（200 wei），使用 send 方法，具有失败处理机制。
withdraw3: 提取合约的全部余额，使用 call 方法，可以动态地转账任意数量的以太币。


转账失败处理: withdraw2 和 withdraw3 使用了错误处理，确保转账成功，防止意外损失。
所有者权限: 所有提取函数都通过 require 检查调用者是否为合约所有者，确保安全性。


getBalance 函数，允许用户查看合约中存储的以太币余额。
*/