// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract WETH {
    /*
        变量声明
        name 代币名称
        symbol 代币符号
        decimals 代币小数位数
    */
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;
    /*
        事件
        Approval 当用户批准某个地址可以支配其代币时触发。
        Transfer：当代币转移时触发。
        Deposit：当用户存入 ETH 时触发。
        Withdraw：当用户提取 WETH 时触发。
    */
    event Approval (address indexed src, address indexed delegateAds, uint256 amount);
    event Transfer (address indexed src, address indexed toAds, uint256 anount);
    event Deposit (address indexed ToAds, uint256 amount);
    event Withdraw(address indexed src, uint256 amount);
    /*
        balanceOf：记录每个地址拥有的 WETH 余额。
        allowance：记录某个地址允许的支配权限。
    */
    mapping (address =>uint256) public balanceOf;
    mapping (address =>mapping (address => uint256)) public allowance;
    /*
        存款
        这个函数允许用户存入 ETH（使用 msg.value 来获取存入的金额）。
        存入后，用户的余额增加，并发出 Deposit 事件。
    */
    function deposit() public payable{
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    /*
        提款
        允许用户提取他们的 WETH。
        要求用户的余额必须大于提取金额。
        提取后，余额减少并将 ETH 转回用户。
        当用户调用 withdraw(uint256 amount) 函数时，合约会确保用户有足够的余额，然后减少用户在 balanceOf 映射中的余额，并将对应的 amount 的以太币通过 payable(msg.sender).transfer(amount) 转给用户。
    */
    function withdraw(uint256 amount) public {
        require(balanceOf[msg.sender] > amount);
        balanceOf[msg.sender] -= amount;
        /*
            payable 特殊的关键字，用于允许地址接收以太币 msg.sender 是发起这次交易的地址，在函数被调用时，msg.sender 指的是调用合约的那个人或合约地址。
                把 msg.sender 变成 payable 类型后，说明这个地址可以接收以太币。
            transfer(amount) 会从当前合约中将 amount 的以太币发送给接收者，这里的接收者是 msg.sender。
        */
        payable (msg.sender) .transfer(amount);
        emit Withdraw(msg.sender, amount);
    }
    /*
        总供应量
        返回合约当前持有的以太币总量，这也可以被视为合约的总供应量。
    */
    function totalSupply() public view returns (uint256){
        return address(this).balance;
    }
    /*
        允许某个地址（delegateAds）支配用户的代币数量（amount）。
        发出 Approval 事件。
    */
    function approve(address delegateAds, uint256 amount) public returns (bool){
        allowance[msg.sender][delegateAds] = amount;
        emit Approval(msg.sender, delegateAds, amount);
        return true;
    }
    /*
        调用 transferFrom 来实现代币转移。
    */
    function transfer(address toAds, uint256 amount) public returns (bool){
        return transferFrom(msg.sender,toAds,amount );
    }
    /*
        实现从一个地址向另一个地址转账的逻辑。
        需要检查余额和允许转账的金额。
    */
    function transferFrom(address src,address toAds,uint256 amount)public returns (bool){
        require(balanceOf[src] >= amount);
        //判断 src 地址是否与 msg.sender 相同
        //如果 src 和 msg.sender 不同，表示 msg.sender 是代替 src 执行转账的，可能是通过 approve 函数获得的授权。
        if(src != msg.sender){
            //src 是否授权了足够的代币额度给 msg.sender
            //allowance[src][msg.sender] 是 src 地址授权给 msg.sender 的代币数量。
            require(allowance[src][msg.sender] >= amount);
            allowance[src][msg.sender] -= amount;
        }
        balanceOf[src] -= amount;
        balanceOf[toAds] += amount;
        //触发 Transfer 事件，记录转账操作。
        //ransferFrom 是用于代币转移的函数，它允许 msg.sender 代表 src 地址进行代币转移，前提是 src 已经授权给 msg.sender 足够的额度。
        emit Transfer(src,toAds,amount);
        return true;
    }
    //fallback 和 receive 函数在合约接收到 ETH 时自动调用，调用 deposit() 函数进行存款。
    fallback() external payable { 
        deposit();
    }
    receive() external payable { 
        deposit();
    }
}