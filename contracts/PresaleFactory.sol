/**
 *Submitted for verification at BscScan.com on 2025-08-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
}

contract Presale {
    address public tokenAddress;
    address public owner;
    uint256 public target;
    uint256 public raised;
    uint256 public startTime;
    uint256 public endTime;

    mapping(address => uint256) public contributions;

    constructor(
        address _tokenAddress,
        address _owner,
        uint256 _target,
        uint256 _startTime,
        uint256 _endTime
    ) {
        tokenAddress = _tokenAddress;
        owner = _owner;
        target = _target;
        startTime = _startTime;
        endTime = _endTime;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function contribute() external payable {
        require(block.timestamp >= startTime, "Presale not started");
        require(block.timestamp <= endTime, "Presale ended");
        require(msg.value > 0, "Send BNB");

        contributions[msg.sender] += msg.value;
        raised += msg.value;
    }

    function claimToken() external {
        require(block.timestamp > endTime, "Presale not ended");
        require(raised >= target, "Target not met");
        require(contributions[msg.sender] > 0, "No contribution");

        uint256 userAmount = contributions[msg.sender];
        contributions[msg.sender] = 0;

        uint8 dec = IERC20(tokenAddress).decimals();
        uint256 tokenAmount = (userAmount * (10 ** dec)) / 1 ether;
        IERC20(tokenAddress).transfer(msg.sender, tokenAmount);
    }

    function refund() external {
        require(block.timestamp > endTime, "Presale not ended");
        require(raised < target, "Target met");
        require(contributions[msg.sender] > 0, "No contribution");

        uint256 amount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function withdrawBNB() external onlyOwner {
        require(block.timestamp > endTime, "Presale not ended");
        require(raised >= target, "Target not met");
        payable(owner).transfer(address(this).balance);
    }

    function depositTokens(uint256 amount) external onlyOwner {
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
    }
}

contract PresaleFactory {
    address public owner;
    address payable public feeReceiver = payable(0xd22217ed1A113b5fcF5B84BF15221bbC5015C9c1);
    uint256 public presaleFee = 0.1 ether;
    uint256 public presaleDuration = 30 days;

    address[] public allPresales;

    event PresaleCreated(address indexed creator, address presaleContract, address tokenAddress, uint256 target);

    constructor() {
        owner = msg.sender;
    }

    function createPresale(address tokenAddress, uint256 target) external payable {
        require(msg.value >= presaleFee, "Insufficient fee");
        require(tokenAddress != address(0), "Invalid token");

        feeReceiver.transfer(presaleFee);

        Presale newPresale = new Presale(
            tokenAddress,
            msg.sender,
            target,
            block.timestamp,
            block.timestamp + presaleDuration
        );

        allPresales.push(address(newPresale));

        emit PresaleCreated(msg.sender, address(newPresale), tokenAddress, target);
    }

    function getAllPresales() external view returns (address[] memory) {
        return allPresales;
    }
}