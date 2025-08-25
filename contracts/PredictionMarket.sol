// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Prediction Market with Chainlink Keepers
contract PredictionMarket is AutomationCompatible, Ownable {
    AggregatorV3Interface internal priceFeed;
    mapping(address => mapping(uint256 => uint256)) public bets;
    mapping(uint256 => bool) public outcomes;
    uint256 public marketId;
    uint256 public resolutionTime;
    uint256 public resolutionInterval = 1 days;

    constructor(address _priceFeed) Ownable(msg.sender) {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function createMarket(uint256 _resolutionTime) external onlyOwner {
        marketId++;
        resolutionTime = _resolutionTime;
    }

    function placeBet(uint256 _marketId, bool outcome) external payable {
        require(_marketId == marketId, "Invalid market");
        require(block.timestamp < resolutionTime, "Market closed");
        bets[msg.sender][_marketId] += msg.value;
        outcomes[_marketId] = outcome;
    }

    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = block.timestamp >= resolutionTime;
        performData = ""; // Explicitly return empty bytes as no specific data is needed for performUpkeep
        return (upkeepNeeded, performData);
    }

    function performUpkeep(bytes calldata) external override {
        require(block.timestamp >= resolutionTime, "Not time yet");
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        // Resolve market based on price feed
        bool finalOutcome = price > 0; // Example condition
        outcomes[marketId] = finalOutcome;
        resolutionTime = block.timestamp + resolutionInterval;
        // Distribute winnings to correct bettors
    }
}