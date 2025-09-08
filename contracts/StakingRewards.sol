// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Staking Rewards with Chainlink Price-Based Adjustments
contract StakingRewards is Ownable {
    using SafeMath for uint256;

    IERC20 public stakingToken;
    IERC20 public rewardToken;
    AggregatorV3Interface public priceFeed;
    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public rewardBalances;
    uint256 public rewardRate = 10; // 10% annual reward
    uint256 public totalStaked;
    uint256 public lastUpdateTime;

    event Staked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);

    constructor(address _stakingToken, address _rewardToken, address _priceFeed) Ownable() {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        updateRewards();
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        stakedBalances[msg.sender] = stakedBalances[msg.sender].add(amount);
        totalStaked = totalStaked.add(amount);
        emit Staked(msg.sender, amount);
    }

    function updateRewards() internal {
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        uint256 timeElapsed = block.timestamp.sub(lastUpdateTime);
        for (uint256 i = 0; i < totalStaked; i++) {
            address user = address(uint160(i)); // Simplified iteration
            if (stakedBalances[user] > 0) {
                uint256 reward = stakedBalances[user].mul(rewardRate).mul(timeElapsed).div(365 days).div(100);
                reward = reward.mul(uint256(price)).div(1e18);
                rewardBalances[user] = rewardBalances[user].add(reward);
            }
        }
        lastUpdateTime = block.timestamp;
    }

    function claimRewards() external {
        updateRewards();
        uint256 reward = rewardBalances[msg.sender];
        require(reward > 0, "No rewards available");
        rewardBalances[msg.sender] = 0;
        require(rewardToken.transfer(msg.sender, reward), "Transfer failed");
        emit RewardClaimed(msg.sender, reward);
    }

    function withdrawStake(uint256 amount) external {
        require(stakedBalances[msg.sender] >= amount, "Insufficient balance");
        updateRewards();
        stakedBalances[msg.sender] = stakedBalances[msg.sender].sub(amount);
        totalStaked = totalStaked.sub(amount);
        require(stakingToken.transfer(msg.sender, amount), "Transfer failed");
    }
}