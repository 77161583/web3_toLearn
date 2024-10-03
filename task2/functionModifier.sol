// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract FunctionModifier {
    /*
        owner：合约的拥有者地址。合约的所有者是合约部署者，通过构造函数设置。
        x：一个公开的 uint256 类型变量，初始值为 10，用于演示修饰器的效果。
        locked：一个 bool 类型变量，用于防止重入攻击的标志。默认为 false。
    */
    address public owner;
    uint256 public x = 10;
    bool public locked;

    constructor() {
        owner = msg.sender;
    }

    //onlyOwner 修饰器确保只有合约的拥有者才能调用使用了这个修饰器的函数。
    modifier onlyOwner() {
        /*
            require：检查调用者的地址 msg.sender 是否等于合约的所有者 owner，如果不是，则回滚并显示 "Not owner" 错误。
            _：特殊符号，用于表示修饰器的结束位置，意味着修饰器的检查通过后将执行函数的主体代码。
        */
        require(msg.sender == owner, "Not owner");
        _;
    }

    /*
        功能：validAddress 修饰器用于验证传入的地址是否为非零地址。
        require：确保传入的地址 _addr 不等于 0x0（即零地址），如果等于零地址，则回滚并显示 "Not valid address" 错误。
        用法：这种修饰器可用于验证地址参数的有效性。
    */
    modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }

    //changeOwner 函数允许当前合约的拥有者将合约的所有权转移给新的地址
    /*
        修饰器的应用：
        onlyOwner：确保只有当前合约的拥有者才能调用该函数。
        validAddress：确保传入的新拥有者地址不是零地址
    */
    function changeOwner(address _newOwner) public onlyOwner validAddress(_newOwner){
        owner = _newOwner;
    }

    //防止重入攻击的修饰器
    modifier noReentrancy() {
        require(!locked, "No reentrancy");
        /*
            locked = true：在函数执行前将 locked 设置为 true，表示函数正在执行，防止重入。
            locked = false：在函数执行完毕后，将 locked 设置为 false，解除锁定，允许下次调用。
        */
        locked = true;
        _;
        locked = false;
    }

    //decrement 函数用于递减 x 的值，按指定的 i 次数递减。如果 i > 1，则递归调用 decrement(i - 1)，每次减少 1。
    //noReentrancy 修饰器：确保函数在执行过程中不会被重入调用，以防止重入攻击。防止在函数执行期间再次进入该函数。
    function decrement(uint256 i) public noReentrancy {
        x -= i;

        if (i > 1) {
            decrement(i - 1);
        }
    }
}
/*
总结：
onlyOwner 修饰器：确保只有合约的拥有者可以调用特定函数。
validAddress 修饰器：验证传入的地址是否有效，防止零地址调用。
noReentrancy 修饰器：防止重入攻击，通过锁定机制确保函数在执行期间不会被重新调用。
递归调用与防重入保护：decrement 函数展示了递归调用的机制，并通过 noReentrancy 修饰器防止重入攻击。

通过这些修饰器，你可以确保函数在特定条件下才能执行，并增强合约的安全性。
*/