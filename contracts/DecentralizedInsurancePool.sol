// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Decentralized Insurance Pool with Chainlink Price Feeds
contract DecentralizedInsurancePool is Ownable {
    using SafeMath for uint256;

    AggregatorV3Interface public priceFeed;
    IERC20 public premiumToken; // Token for premium payments
    struct Policy {
        address insured;
        uint256 premium;
        uint256 coverageAmount;
        uint256 startTime;
        uint256 expiry;
        bool active;
        address asset; // Covered asset
    }
    mapping(address => mapping(uint256 => Policy)) public policies;
    mapping(address => uint256) public policyCount;
    uint256 public totalPremiums;
    uint256 public totalCoverage;
    uint256 public premiumRate = 2; // 2% annual premium

    event PolicyPurchased(address indexed insured, uint256 policyId, uint256 premium, uint256 coverage);
    event ClaimProcessed(address indexed insured, uint256 policyId, uint256 payout);

    constructor(address _priceFeed, address _premiumToken) Ownable() {
        priceFeed = AggregatorV3Interface(_priceFeed);
        premiumToken = IERC20(_premiumToken);
    }

    function purchasePolicy(address asset, uint256 coverageAmount, uint256 duration) external {
        require(duration <= 365 days, "Duration too long");
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        uint256 premium = coverageAmount.mul(premiumRate).mul(duration).div(365 days).div(100);
        require(premiumToken.transferFrom(msg.sender, address(this), premium), "Premium payment failed");
        uint256 policyId = policyCount[msg.sender]++;
        policies[msg.sender][policyId] = Policy({
            insured: msg.sender,
            premium: premium,
            coverageAmount: coverageAmount,
            startTime: block.timestamp,
            expiry: block.timestamp + duration,
            active: true,
            asset: asset
        });
        totalPremiums = totalPremiums.add(premium);
        totalCoverage = totalCoverage.add(coverageAmount);
        emit PolicyPurchased(msg.sender, policyId, premium, coverageAmount);
    }

    function fileClaim(uint256 policyId) external {
        Policy memory policy = policies[msg.sender][policyId];
        require(policy.active, "Policy not active");
        require(block.timestamp <= policy.expiry, "Policy expired");
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        // Example: Claim if asset price drops by 20%
        uint256 currentPrice = uint256(price);
        require(currentPrice < 80 * 10**18 / 100, "Price above claim threshold");
        uint256 payout = policy.coverageAmount;
        require(premiumToken.balanceOf(address(this)) >= payout, "Insufficient pool funds");
        policies[msg.sender][policyId].active = false;
        totalCoverage = totalCoverage.sub(policy.coverageAmount);
        require(premiumToken.transfer(msg.sender, payout), "Payout failed");
        emit ClaimProcessed(msg.sender, policyId, payout);
    }

    function withdrawPremiums(uint256 amount) external onlyOwner {
        require(premiumToken.balanceOf(address(this)) >= amount, "Insufficient balance");
        require(premiumToken.transfer(owner(), amount), "Withdrawal failed");
        totalPremiums = totalPremiums.sub(amount);
    }
}