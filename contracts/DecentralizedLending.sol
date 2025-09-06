// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Decentralized Lending with Chainlink Price Feeds
contract DecentralizedLending is Ownable {
    AggregatorV3Interface internal priceFeed;
    mapping(address => uint256) public collateral;
    mapping(address => uint256) public loans;
    uint256 public loanToValueRatio = 50; // 50% LTV
    uint256 public interestRate = 5; // 5% annual interest
    uint256 public loanDuration = 365 days;

    constructor(address _priceFeed) Ownable(msg.sender) {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function depositCollateral() external payable {
        collateral[msg.sender] += msg.value;
    }

    function borrow(uint256 amount) external {
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        uint256 collateralValue = (collateral[msg.sender] * uint256(price)) / 1e18;
        uint256 maxLoan = (collateralValue * loanToValueRatio) / 100;
        require(amount <= maxLoan, "Exceeds LTV ratio");
        loans[msg.sender] += amount;
        payable(msg.sender).transfer(amount);
    }

    function repayLoan() external payable {
        require(loans[msg.sender] > 0, "No loan to repay");
        uint256 interest = (loans[msg.sender] * interestRate * (block.timestamp - loans[msg.sender])) / (100 * loanDuration);
        require(msg.value >= loans[msg.sender] + interest, "Insufficient repayment");
        loans[msg.sender] = 0;
        collateral[msg.sender] = 0;
    }
}