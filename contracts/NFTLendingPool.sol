// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// NFT Lending Pool with Chainlink Price Feeds
contract NFTLendingPool is Ownable {
    using SafeMath for uint256;

    IERC721 public nft;
    IERC20 public lendingToken;
    AggregatorV3Interface public priceFeed;
    struct Loan {
        uint256 tokenId;
        uint256 amount;
        uint256 startTime;
        bool active;
    }
    mapping(address => mapping(uint256 => Loan)) public loans;
    mapping(address => uint256) public loanCount;
    uint256 public minLoanValue = 100 * 10**18; // Minimum loan amount
    uint256 public interestRate = 3; // 3% interest

    event LoanTaken(address indexed borrower, uint256 loanId, uint256 tokenId, uint256 amount);
    event LoanRepaid(address indexed borrower, uint256 loanId, uint256 amount);

    constructor(address _nft, address _lendingToken, address _priceFeed) Ownable(msg.sender) {
        nft = IERC721(_nft);
        lendingToken = IERC20(_lendingToken);
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function takeLoan(uint256 tokenId, uint256 amount) external {
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        require(amount >= minLoanValue, "Loan too small");
        require(lendingToken.balanceOf(address(this)) >= amount, "Insufficient liquidity");
        nft.transferFrom(msg.sender, address(this), tokenId);
        uint256 loanId = loanCount[msg.sender]++;
        loans[msg.sender][loanId] = Loan({
            tokenId: tokenId,
            amount: amount,
            startTime: block.timestamp,
            active: true
        });
        require(lendingToken.transfer(msg.sender, amount), "Transfer failed");
        emit LoanTaken(msg.sender, loanId, tokenId, amount);
    }

    function repayLoan(uint256 loanId) external {
        Loan memory loan = loans[msg.sender][loanId];
        require(loan.active, "Loan not active");
        uint256 interest = loan.amount.mul(interestRate).mul(block.timestamp.sub(loan.startTime)).div(365 days).div(100);
        uint256 totalRepayment = loan.amount.add(interest);
        require(lendingToken.transferFrom(msg.sender, address(this), totalRepayment), "Repayment failed");
        loans[msg.sender][loanId].active = false;
        nft.transferFrom(address(this), msg.sender, loan.tokenId);
        emit LoanRepaid(msg.sender, loanId, totalRepayment);
    }
}