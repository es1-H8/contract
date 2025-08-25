// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Automated Yield Farming with Chainlink Automation
contract YieldFarmAutomation is AutomationCompatible, Ownable {
    AggregatorV3Interface internal priceFeed;
    uint256 public lastRebalance;
    uint256 public rebalanceInterval = 1 days;
    address public token; // ERC20 token for staking
    mapping(address => uint256) public stakes;
    uint256 public totalStaked;

    constructor(address _priceFeed, address _token) Ownable() {
        priceFeed = AggregatorV3Interface(_priceFeed);
        token = _token;
    }

    function stake(uint256 amount) external {
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Transfer failed");
        stakes[msg.sender] += amount;
        totalStaked += amount;
    }

    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory) {
        (, int256 price,,,) = priceFeed.latestRoundData();
        bool priceCondition = price > 0; // Add complex price logic here
        upkeepNeeded = (block.timestamp >= lastRebalance + rebalanceInterval) && priceCondition;
    }

    function performUpkeep(bytes calldata) external override {
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(block.timestamp >= lastRebalance + rebalanceInterval, "Too soon");
        require(price > 0, "Invalid price data");
        lastRebalance = block.timestamp;
        // Rebalance logic: e.g., adjust staking rewards based on price
        // This could involve complex calculations for yield distribution
    }

    function withdrawStake(uint256 amount) external {
        require(stakes[msg.sender] >= amount, "Insufficient stake");
        stakes[msg.sender] -= amount;
        totalStaked -= amount;
        require(IERC20(token).transfer(msg.sender, amount), "Transfer failed");
    }
}