// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Decentralized Insurance Contract with Chainlink Price Feeds
contract DecentralizedInsurance is Ownable {
    AggregatorV3Interface internal priceFeed;
    mapping(address => uint256) public premiums;
    mapping(address => uint256) public claims;
    uint256 public totalPool;
    uint256 public premiumRate = 1 ether; // Premium in USD
    uint256 public claimThreshold; // Asset price threshold for claim eligibility

    constructor(address _priceFeed) Ownable(msg.sender) {
        priceFeed = AggregatorV3Interface(_priceFeed); // e.g., ETH/USD feed
    }

    function payPremium() external payable {
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        uint256 premiumInEth = (premiumRate * 1e18) / uint256(price);
        require(msg.value >= premiumInEth, "Insufficient premium");
        premiums[msg.sender] += msg.value;
        totalPool += msg.value;
    }

    function fileClaim(uint256 amount) external {
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price < int256(claimThreshold), "Price above claim threshold");
        require(premiums[msg.sender] > 0, "No premium paid");
        require(totalPool >= amount, "Insufficient pool funds");
        claims[msg.sender] += amount;
        totalPool -= amount;
        payable(msg.sender).transfer(amount);
    }

    function setClaimThreshold(uint256 _threshold) external onlyOwner {
        claimThreshold = _threshold;
    }
}