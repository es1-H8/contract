// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

library ConvertLib {
    function convert(uint256 amount, uint256 conversionRate) public pure returns (uint256 convertedAmount) {
        return amount * conversionRate;
    }
}

contract MetaCoin {
    mapping(address => uint256) private balances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    constructor() {
        balances[tx.origin] = 10000;
    }

    function sendCoin(address receiver, uint256 amount) public returns (bool sufficient) {
        if (balances[msg.sender] < amount) return false;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Transfer(msg.sender, receiver, amount);
        return true;
    }

    function getBalanceInEth(address addr) public view returns (uint256) {
        return ConvertLib.convert(getBalance(addr), 2);
    }

    function getBalance(address addr) public view returns (uint256) {
        return balances[addr];
    }
}