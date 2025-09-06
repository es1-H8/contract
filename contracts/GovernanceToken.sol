// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Governance Token with Staking and Chainlink Price-Based Rewards
contract GovernanceToken is ERC20, Ownable {
    using SafeMath for uint256;

    AggregatorV3Interface public priceFeed;
    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public stakeStartTime;
    uint256 public totalStaked;
    uint256 public rewardRate = 10; // 10% annual reward based on price
    uint256 public totalRewardsDistributed;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 amount);

    constructor(address _priceFeed) ERC20("GovernanceToken", "GOV") Ownable(msg.sender) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        _mint(msg.sender, 1_000_000 * 10**18); // 1M tokens
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Invalid stake amount");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _burn(msg.sender, amount);
        stakedBalances[msg.sender] = stakedBalances[msg.sender].add(amount);
        stakeStartTime[msg.sender] = block.timestamp;
        totalStaked = totalStaked.add(amount);
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(stakedBalances[msg.sender] >= amount, "Insufficient staked balance");
        stakedBalances[msg.sender] = stakedBalances[msg.sender].sub(amount);
        totalStaked = totalStaked.sub(amount);
        _mint(msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }

    function claimRewards() external {
        uint256 stakedAmount = stakedBalances[msg.sender];
        require(stakedAmount > 0, "No staked balance");
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        uint256 reward = stakedAmount.mul(rewardRate).mul(block.timestamp.sub(stakeStartTime[msg.sender])).div(365 days).div(100);
        reward = reward.mul(uint256(price)).div(1e18); // Adjust reward by asset price
        _mint(msg.sender, reward);
        totalRewardsDistributed = totalRewardsDistributed.add(reward);
        stakeStartTime[msg.sender] = block.timestamp;
        emit RewardsClaimed(msg.sender, reward);
    }

    function updateRewardRate(uint256 newRate) external onlyOwner {
        require(newRate <= 50, "Reward rate too high");
        rewardRate = newRate;
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}