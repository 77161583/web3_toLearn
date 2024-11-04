// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract CrowdFunding {
    address public immutable beneficiary;   //受益人的地址，众筹成功后将获得资金。
    uint256 public immutable fundingGoal;   //目标金额，众筹必须达到的金额。
    uint256 public fundingAmount;           //当前已筹集的金额。
    mapping (address=> uint256) public funders; //记录每个捐赠者捐赠的金额。
    mapping (address=>bool) private fundersInserted; //记录捐赠者是否已插入（用于避免重复插入）。
    address[] public fundersKey;    // 存储捐赠者的地址列表。

    bool public AVAILABLED = true;  //众筹是否可用的状态，初始值为 true。

    //接收受益人地址和目标金额并初始化状态变量。
    constructor(address _beneficiary,uint256 _goal){
        beneficiary = _beneficiary;
        fundingGoal = _goal;
    }


    function contribute() external payable{
        //确保众筹是开放的
        require(AVAILABLED,"CrowdFunding is closed");
        
        // 计算潜在的总筹集金额 potentiaFundingAmount，并检查是否超过目标金额。
        uint256 potentiaFundingAmount = fundingAmount + msg.value;
        uint256 refundAmount = 0;

        //如果超过目标金额，计算退款金额，并更新捐赠者的捐款和已筹集金额。
        if(potentiaFundingAmount > fundingGoal){
            refundAmount = potentiaFundingAmount - fundingGoal;
            funders[msg.sender] += (msg.value - refundAmount);
            fundingAmount += (msg.value - refundAmount);
        }else{
            //如果没有超过目标金额，直接更新捐赠者的捐款和已筹集金额。
            //检查捐赠者是否已存在于 funders 中，如果没有，则插入并更新 fundersKey。
            funders[msg.sender] += msg.value;
            fundingAmount += msg.value;
        }

        // 更新捐赠者信息 检查捐赠者是否已存在于 funders 中，如果没有，则插入并更新 fundersKey。
        if(!fundersInserted[msg.sender]){
            fundersInserted[msg.sender] = true;
            fundersKey.push(msg.sender );

        }

        // 退还多余的金额
        if(refundAmount > 0){
            payable (msg.sender).transfer(refundAmount);
        }
    }

    // 关闭
    function close() external returns (bool){
        //1.检查 首先检查当前筹集金额是否达到了目标金额，若未达到则返回 false。
        if(fundingAmount < fundingGoal){
            return false;
        }
        uint256 amount = fundingAmount;

        //2.修改   将已筹集的金额转移给受益人，并将状态变量 AVAILABLED 设置为 false。
        fundingAmount  = 0;
        AVAILABLED = false;

        //3.操作 
        payable (beneficiary).transfer(amount);
        return true;
    }

    //获取捐赠者数量
    function fundersLength() public view returns (uint256){
        return fundersKey.length;
    }

}