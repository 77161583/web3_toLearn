// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ERC20.sol";

contract MyToken is ERC20 {
    //映射存储账户余额
    mapping(address => uint) private balances;
    //存储每个账户的授权额度
    mapping (address => mapping(address=>uint)) private allowed;
    //总供应量
    uint private _totalSupply;

    //构造函数，初始化代币总供应量，并分配给部署者
    constructor(uint totalSupply_){
        _totalSupply = totalSupply_ * (10 ** uint(decimals));
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0),msg.sender,_totalSupply); //记录事件
    }

    //实现totalSupply
    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    // 实现balanceOf 方法
    function balanceOf(address tokenOwner) public view override returns (uint balance){
        return balances[tokenOwner];
    }

    // 实现 transfer 方法
    function transfer(address to, uint tokens) public override returns (bool success){
        require(balances[msg.sender] >= tokens, "Insufficaient balance");
        balances[msg.sender] -= tokens;
        balances[to] += tokens;
        emit Transfer(msg.sender,to,tokens);
        return true;
    }

    // 实现 allowance 方法
    function allowance(address tokenOwner,address spender) public view override returns(uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // 实现 approve 方法
    function approve (address spender, uint tokens) public override returns (bool success){
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }

    // 实现 transferFrom
    function transferFrom(address from, address to, uint tokens) public override returns (bool success){
        require(balances[from] >= tokens, "Insufficient balance");
        require(allowed[from][msg.sender] >= tokens,"Allowance exceeded");

        balances[from] -= tokens;
        allowed[from][msg.sender] -= tokens;
        balances[to] += tokens;

        emit Transfer(from,to,tokens);
        return true;
    }
}