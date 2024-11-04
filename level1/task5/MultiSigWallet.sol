// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MultiSigWallet {
    address[] public owners; //存储所有者地址的数组。
    mapping (address => bool) public isOwner; // 映射，用于判断某个地址是否是所有者。
    uint256 public required; //表示批准一个交易所需的最低所有者数量。

    //定义了一个结构体 Transaction，用于表示交易的详细信息，包括目标地址、转账金额、附加数据和是否已执行的标志。
    struct Transaction{
        address to;
        uint256 value;
        bytes data;
        bool exected;
    }

    //transactions: 存储所有提交的交易。
    Transaction[] public transactions;

    //approved: 映射，用于跟踪每笔交易的批准情况    
    mapping (uint256 => mapping (address=>bool))public approved;

    //定义了多个事件，用于记录不同操作的发生。
    event Deposit(address indexed  sender,uint256 amount);      //当合约接收到以太币时触发。 sender: 发送者的地址，表示向合约存入以太币的人。 amount: 存入的以太币数量。
    event Sumbit(uint256 indexed txId);                         //当新交易被提交时触发。 txId: 提交的交易的唯一标识符（ID），用于标识和检索该交易。
    event Approve(address indexed owner,uint256 indexed txId);  //当某个所有者批准交易时触发。 owner: 批准交易的所有者地址。 txId: 被批准的交易的唯一标识符。
    event Revoke(address indexed owner,uint256 indexed txId);   //当某个所有者撤销对交易的批准时触发。owner: 撤销批准的所有者地址。txId: 被撤销批准的交易的唯一标识符。
    event Execute(uint256 indexed txId);                        //当交易被执行时触发。txId: 被执行的交易的唯一标识符。

    //接收以太币的函数 receive 函数允许合约接收以太币，并记录存款事件。
    receive() external payable { 
        emit Deposit(msg.sender, msg.value);
    }

    /*
        修饰符
        onlyOwner: 确保调用者是所有者。
        txExisits: 确保交易 ID 是有效的。
        notApproved: 确保调用者尚未批准该交易。
        notExecuted: 确保该交易尚未执行。
    */
    modifier onlyOwner(){
        require(isOwner[msg.sender],"not owner");
        _;
    }

    modifier txExisits(uint256 _txId){
        require(_txId < transactions.length, "tx doesn't exist");
        _;
    }

    modifier notApproved(uint256 _txId){
        require(!approved[_txId][msg.sender],"tx already approved");
        _;
    }

    modifier notExecuted(uint256 _txId){
        require(!transactions[_txId].exected,"tx is exected");
        _;
    }

    /*
        构造函数初始化合约所有者和所需的批准数，进行必要的验证。

        _owners: 所有者地址数组，表示多签钱包的所有者。
        _required: 进行交易时所需的批准数量。
    */
    constructor(address[] memory _owners,uint256 _required) {
        //检查所有者数组的长度是否大于 0. 确保至少有一个所有者，如果没有，则会抛出错误并停止执行。
        require(_owners.length > 0, "owner requeired");
        //确保所需的批准数量 required 大于 0 且小于或等于所有者的数量。 确保不可能要求比所有者数量还多的批准次数，否则会抛出错误。
        require(
            _required >0 && _required <= _owners.length,
            "invalid required number of owners"
        );
        //逻辑: 遍历所有者地址数组 _owners。
        for(uint256 index = 0; index < _owners.length; index++){
            address owner = _owners[index];
            //检查当前所有者地址是否为零地址（即无效地址）。 确保所有者地址有效，如果无效则抛出错误。
            require(owner != address(0),"invalid owner");
            //检查当前所有者是否已经存在于 isOwner 映射中。确保每个所有者地址是唯一的，如果不是则抛出错误。
            require(!isOwner[owner],"owner is not unique");
            //将当前所有者地址标记为有效，存储在 isOwner 映射中
            isOwner[owner] = true;
            //将当前所有者地址添加到 owners 数组中，记录所有者列表。
            owners.push(owner);
        }
        // 将所需的批准数量 required 设置为传入的值 _required。
        required = _required;
    }

    //获取余额 返回合约的以太币余额。
    function getBalance() external view returns (uint256){
        return address(this).balance;
    }

    //提交交易 提交新的交易并返回交易 ID。
    function submit(address _to, uint256 _value, bytes calldata _data) external onlyOwner returns(uint256){
        /*
            将新的交易信息添加到 transactions 数组中。
            _to: 目标地址（接收者）。
            _value: 交易金额。
            _data: 附加数据。
            _exected: 交易是否已执行，初始化为 false。
        */ 
        transactions.push(
            Transaction({to: _to,value:_value,data:_data,exected:false})
        );
        //触发 Sumbit 事件，记录交易的 ID（在 transactions 数组中的索引）。 让外部应用（如前端界面）能够监听到新交易的提交，并获取交易的唯一标识符。
        emit Sumbit(transactions.length - 1);
        // 返回新提交交易在 transactions 数组中的索引（ID) 允许调用者知道新交易的标识符，方便后续的批准和执行。
        return transactions.length - 1;
    }

    //批准交易
    function approv(uint256 _txId) external onlyOwner txExisits(_txId) notApproved(_txId) notExecuted(_txId){
        //将当前调用者（msg.sender）对特定交易（_txId）的批准状态设置为 true。
        approved[_txId][msg.sender] = true;
        //触发 Approve 事件，记录批准的操作。
        emit Approve(msg.sender, _txId);
    }
    
    //执行交易
    function execute(uint256 _txId) external onlyOwner txExisits(_txId) notExecuted(_txId){
        //先调用 getApprovalCount 函数，确保批准此交易的所有者数量不少于所需数量 (required)。如果不满足条件，抛出异常。
        require(getApprovalCount(_txId) >= required,"approvals < required");
        //获取交易信息: 从 transactions 数组中获取对应的交易，并将其 exected 属性设置为 true，表示该交易已被执行。
        Transaction storage transaction = transactions[_txId];
        transaction.exected = true;
        //使用 call 方法将资金转账到指定的地址 (transaction.to)，同时传递任何附加数据 (transaction.data)。 transaction.value 指定要发送的以太币数量。
        (bool sucess, ) = transaction.to.call{value:transaction.value}(
            transaction.data
        );
        //检查调用是否成功: 如果 call 方法返回 false，则抛出异常，表明交易执行失败。
        require(sucess,"tx failed");
        //触发事件: 记录交易的执行，通过 Execute 事件通知外部监听者。
        emit Execute(_txId);
    }

    //返回指定交易的批准数量。 _txId 是交易的 ID。
    function getApprovalCount(uint256 _txId) 
        public 
        view 
        returns(uint256 count) 
    {
        //循环遍历所有者: 遍历所有的合约所有者，检查每个所有者是否批准了指定的交易   如果该所有者已批准交易，则计数器 (count) 增加 1
        for (uint256 index = 0; index < owners.length; index++){
            if (approved[_txId][owners[index]]) {
                count += 1;
            }
        } 
    }

    /*
        撤销交易
        external: 表示该函数只能在合约外部被调用。
        onlyOwner: 限制调用者必须是合约的所有者，确保只有拥有者可以撤销交易。
        txExisits(_txId): 确保交易 ID _txId 存在。
        notExecuted(_txId): 确保该交易尚未执行。
    */
    function revoke(uint256 _txId)
        external 
        onlyOwner
        txExisits(_txId)
        notExecuted(_txId)
    {
        //检查批准状态: 使用 require 语句确认调用者 (msg.sender) 是否已批准指定的交易。如果没有批准，抛出异常，提示“交易未被批准”。
        require(approved[_txId][msg.sender],"tx not approved");
        //撤销批准: 将 approved 映射中对应的值设置为 false，表示该调用者对这笔交易的批准被撤销。
        approved[_txId][msg.sender] = false;
        //触发事件: 通过 Revoke 事件记录撤销操作，以便外部监听者能够捕捉到这一变化。
        emit Revoke(msg.sender, _txId);
    }
}