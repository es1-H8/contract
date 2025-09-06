/**
 *Submitted for verification at Etherscan.io on 2025-08-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract USDTFlashTest {
    address public owner;
    IERC20 public usdt;

    constructor(address _usdt) {
        owner = msg.sender;
        usdt = IERC20(_usdt);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // User deposits USDT
    function flashIn(uint256 amount) external {
        require(usdt.transferFrom(msg.sender, address(this), amount), "flashIn failed");
    }

    // Owner withdraws USDT to own address
    function flashOut(uint256 amount) external onlyOwner {
        require(usdt.transfer(owner, amount), "flashOut failed");
    }

    // Read USDT balance
    function getContractUSDTBalance() external view returns (uint256) {
        return usdt.balanceOf(address(this));
    }
}