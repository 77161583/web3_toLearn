// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

//存储在临时存储器中的数据在交易后被清除。
/*
Storage：区块链上的持久化存储，数据永远保存在链上。
Memory：函数调用期间的临时存储，调用结束后数据被清除。
Transient Storage（瞬态存储）：数据在交易结束时被清除。它是即将到来的 Cancun 硬分叉中提出的一种新的存储机制，适用于短期存储需求。
*/

/*
ITest 是一个接口，定义了两个函数：

val()：外部只读函数，返回一个 uint256 值。
test()：外部调用函数。
*/
interface ITest {
    function val() external view returns (uint256);
    function test() external;
}


/*
val 变量：存储一个 uint256 值，公开可读。
fallback() 函数：这是一个特殊函数，当合约接收到不匹配任何函数签名的调用时会触发。这里它通过接口 ITest 调用调用者（msg.sender）的 val() 函数，并将结果存储在 val 变量中。
test() 函数：它调用目标地址 target 上的 ITest(target).test() 函数。
*/
contract Callback {
    uint256 public val;

    fallback() external {
        val = ITest(msg.sender).val();
    }

    function test(address target) external {
        ITest(target).test();
    }
}


/*
val 变量：公开存储一个 uint256 值。
test() 函数：设置 val 为 123，然后通过 msg.sender.call(b) 进行低级调用，b 是一个空字节数组，表示没有附带任何数据。call 是一种低级别的以太坊调用方式。
*/
contract TestStorage {
    uint256 public val;

    function test() public {
        val = 123;
        bytes memory b = "";
        msg.sender.call(b);
    }
}

/*
SLOT 常量：指定了一个瞬态存储的槽（槽位 0），用于存储数据。
test() 函数：使用内联汇编 tstore(SLOT, 321) 将值 321 存储在瞬态存储槽中。之后同样执行低级 call。
val() 函数：通过 tload(SLOT) 读取瞬态存储槽中的值并返回。
瞬态存储的数据在每次交易结束后会自动清除，因此这种存储在交易结束后不会保留。
*/
contract TestTransientStorage {
    bytes32 constant SLOT = 0;

    function test() public {
        assembly {
            tstore(SLOT, 321)
        }
        bytes memory b = "";
        msg.sender.call(b);
    }

    function val() public view returns (uint256 v) {
        assembly {
            v := tload(SLOT)
        }
    }
}

/*
防重入攻击（Reentrancy Guard）：这是经典的防重入攻击模式，locked 标志用于防止函数被递归调用（即重入攻击）。在函数调用前设置 locked 为 true，在函数结束后恢复为 false。
test() 函数：在调用时使用 lock 修饰器，防止重入调用。执行一个低级别的 call，忽略返回值。
*/
contract ReentrancyGuard {
    bool private locked;

    modifier lock() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }

    function test() public lock {
        bytes memory b = "";
        msg.sender.call(b);
    }
}

/*
瞬态存储版本的防重入保护：类似 ReentrancyGuard，但使用瞬态存储槽来实现防重入机制。
lock() 修饰器：使用内联汇编通过 tload 和 tstore 操作瞬态存储。函数执行前检查槽是否被占用，如果被占用则回退交易，否则设置槽值为 1。执行完成后重置槽值为 0。
test() 函数：与前面类似，使用 lock 修饰器来防止重入攻击，并执行低级别调用。
相比传统的防重入机制，这里使用瞬态存储减少了存储写入的成本，从而降低了 Gas 消耗。
*/
contract ReentrancyGuardTransient {
    bytes32 constant SLOT = 0;

    modifier lock() {
        assembly {
            if tload(SLOT) { revert(0, 0) }
            tstore(SLOT, 1)
        }
        _;
        assembly {
            tstore(SLOT, 0)
        }
    }

    function test() external lock {
        bytes memory b = "";
        msg.sender.call(b);
    }
}