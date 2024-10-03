// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Enum {
    //定义了一个枚举类型 Status，代表运输状态。枚举的每个成员实际上对应一个 uint 整数，从 0 开始依次递增
    enum Status {
        Pending,
        Shipped,
        Accepted,
        Rejected,
        Canceled
    }
    // 这是一个 Status 类型的状态变量，默认值为枚举的第一个值，即 Pending（对应 0）。
    // public 关键字意味着 Solidity 会为这个状态变量自动生成一个 getter 函数，允许外部访问当前状态。
    Status public status;

    //读取并返回当前的状态值（读取）
    //返回的是 枚举
    //view 说明该函数不会修改合约的状态，只是读取数据。
    function get() public view returns (Status) {
        return status;
    }

    //set 函数允许外部用户通过传入一个 Status 枚举值来更新 status。（设置）
    //_status 是函数参数，类型为 Status，表示要设置的新状态。
    //例如，如果调用 set(Status.Shipped)，则状态会被更新为 Shipped（值为 1）。
    function set(Status _status) public {
        status = _status;
    }

    //功能：cancel 函数直接将状态更新为 Canceled（取消），不需要传入参数。
    //内部逻辑：调用此函数会将 status 变量设置为 Status.Canceled，即枚举的第五个值（对应 4）。
    function cancel() public {
        status = Status.Canceled;
    }

    //功能：reset 函数用于将状态重置为枚举的默认值，也就是第一个枚举值 Pending（对应 0）。（重置）
    //delete 关键字：delete 在 Solidity 中用于将状态变量恢复到默认值。对于枚举类型，默认值是它的第一个枚举成员（Pending）。
    function reset() public {
        delete status;
    }




}

