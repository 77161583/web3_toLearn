// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EtherUints {
    //交易是用 ehter支付的。
    // 1 ether = 10的18次方 wei

    

    uint256 public oneWei = 1 wei;
    // 1 wei is equal to 1
    bool public isOweWei = (oneWei == 1);

    uint256 public oneGwei = 1 gwei;
    //1 gwei is equal to 10^9 gwei
    bool public isOneGwei = (oneGwei == 1e18);

    uint256 public oneEther = 1 ether;
    // 1 ether is equal to 10^18 wei
    bool public isOneEther = (oneEther == 1e18);
}