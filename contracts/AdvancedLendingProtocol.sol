// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Advanced Lending Protocol with Chainlink Price Feeds and Liquidations
contract AdvancedLendingProtocol is Ownable {
    using SafeMath for uint256;

    AggregatorV3Interface internal priceFeed;
    IERC20 public lendingToken; // Stablecoin for lending (e.g., DAI)
    mapping(address => uint256) public collateral; // User collateral in ETH
    mapping(address => uint256) public loans; // User loans in lendingToken
    mapping(address => uint256) public loanStartTime; // Timestamp of loan issuance
    uint256 public loanToValueRatio = 75; // 75% LTV
    uint256 public liquidationThreshold = 80; // Liquidation at 80% LTV
    uint256 public interestRate = 5; // 5% annual interest
    uint256 public liquidationPenalty = 10; // 10% penalty on liquidation
    uint256 public totalCollateral;
    uint256 public totalBorrowed;

    event LoanIssued(address indexed borrower, uint256 amount, uint256 collateralBalance);
    event LoanRepaid(address indexed borrower, uint256 amount, uint256 interest);
    event Liquidation(address indexed borrower, uint256 collateralSeized, uint256 debtRepaid);

    constructor(address _priceFeed, address _lendingToken) Ownable() {
        priceFeed = AggregatorV3Interface(_priceFeed); // e.g., ETH/USD
        lendingToken = IERC20(_lendingToken);
    }

    function depositCollateral() external payable {
        require(msg.value > 0, "No collateral provided");
        collateral[msg.sender] = collateral[msg.sender].add(msg.value);
        totalCollateral = totalCollateral.add(msg.value);
    }

    function borrow(uint256 amount) external {
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        uint256 collateralValue = collateral[msg.sender].mul(uint256(price)).div(1e18);
        uint256 maxLoan = collateralValue.mul(loanToValueRatio).div(100);
        require(amount <= maxLoan, "Exceeds LTV ratio");
        require(lendingToken.balanceOf(address(this)) >= amount, "Insufficient liquidity");
        loans[msg.sender] = loans[msg.sender].add(amount);
        loanStartTime[msg.sender] = block.timestamp;
        totalBorrowed = totalBorrowed.add(amount);
        require(lendingToken.transfer(msg.sender, amount), "Transfer failed");
        emit LoanIssued(msg.sender, amount, collateral[msg.sender]);
    }

    function repayLoan(uint256 amount) external {
        require(loans[msg.sender] >= amount, "Invalid repayment amount");
        uint256 interest = loans[msg.sender].mul(interestRate).mul(block.timestamp.sub(loanStartTime[msg.sender])).div(365 days).div(100);
        uint256 totalRepayment = amount.add(interest);
        require(lendingToken.transferFrom(msg.sender, address(this), totalRepayment), "Repayment failed");
        loans[msg.sender] = loans[msg.sender].sub(amount);
        totalBorrowed = totalBorrowed.sub(amount);
        emit LoanRepaid(msg.sender, amount, interest);
    }

    function liquidate(address borrower) external {
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        uint256 collateralValue = collateral[borrower].mul(uint256(price)).div(1e18);
        uint256 loanValue = loans[borrower];
        uint256 ltv = loanValue.mul(100).div(collateralValue);
        require(ltv >= liquidationThreshold, "LTV below liquidation threshold");
        uint256 collateralToSeize = collateral[borrower];
        uint256 debtToRepay = loans[borrower].mul(100 + liquidationPenalty).div(100);
        require(lendingToken.transferFrom(msg.sender, address(this), debtToRepay), "Liquidation payment failed");
        collateral[borrower] = 0;
        loans[borrower] = 0;
        totalCollateral = totalCollateral.sub(collateralToSeize);
        totalBorrowed = totalBorrowed.sub(loans[borrower]);
        payable(msg.sender).transfer(collateralToSeize);
        emit Liquidation(borrower, collateralToSeize, debtToRepay);
    }

    function updateParameters(uint256 _ltv, uint256 _liquidationThreshold, uint256 _interestRate) external onlyOwner {
        require(_ltv <= 90, "LTV too high");
        require(_liquidationThreshold > _ltv, "Invalid liquidation threshold");
        loanToValueRatio = _ltv;
        liquidationThreshold = _liquidationThreshold;
        interestRate = _interestRate;
    }
}