// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Tiered Staking Platform with Chainlink Price Feed for Dynamic Rewards
contract TieredStakingPlatform is Ownable {
    IERC20 public stakingToken;
    IERC20 public rewardToken;
    AggregatorV3Interface public priceFeed;
    
    struct Tier {
        uint256 minStake; // Minimum stake to qualify for tier
        uint256 rewardMultiplier; // Reward multiplier (e.g., 100 = 1x, 150 = 1.5x)
        uint256 lockPeriod; // Lock period in seconds
    }
    
    struct Stake {
        uint256 amount;
        uint256 tierId;
        uint256 startTime;
        uint256 lastClaimTime;
        bool active;
    }
    
    mapping(uint256 => Tier) public tiers;
    mapping(address => mapping(uint256 => Stake)) public stakes;
    mapping(address => uint256) public stakeCount;
    uint256 public tierCount;
    uint256 public totalStaked;
    uint256 public baseRewardRate = 10; // 10% annual reward
    uint256 public totalRewardsDistributed;
    
    event TierAdded(uint256 indexed tierId, uint256 minStake, uint256 rewardMultiplier, uint256 lockPeriod);
    event Staked(address indexed user, uint256 stakeId, uint256 amount, uint256 tierId);
    event Unstaked(address indexed user, uint256 stakeId, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 stakeId, uint256 amount);

    constructor(address _stakingToken, address _rewardToken, address _priceFeed) Ownable(msg.sender) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function addTier(uint256 minStake, uint256 rewardMultiplier, uint256 lockPeriod) external onlyOwner {
        require(minStake > 0, "Invalid min stake");
        require(rewardMultiplier >= 100, "Invalid multiplier");
        require(lockPeriod >= 1 days, "Invalid lock period");
        tiers[tierCount] = Tier({
            minStake: minStake,
            rewardMultiplier: rewardMultiplier,
            lockPeriod: lockPeriod
        });
        emit TierAdded(tierCount, minStake, rewardMultiplier, lockPeriod);
        tierCount++;
    }

    function stake(uint256 amount, uint256 tierId) external {
        require(tierId < tierCount, "Invalid tier");
        require(amount >= tiers[tierId].minStake, "Below minimum stake");
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        
        uint256 stakeId = stakeCount[msg.sender]++;
        stakes[msg.sender][stakeId] = Stake({
            amount: amount,
            tierId: tierId,
            startTime: block.timestamp,
            lastClaimTime: block.timestamp,
            active: true
        });
        
        totalStaked += amount;
        emit Staked(msg.sender, stakeId, amount, tierId);
    }

    function calculateRewards(address user, uint256 stakeId) public view returns (uint256) {
        Stake memory userStake = stakes[user][stakeId];
        if (!userStake.active) return 0;
        
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        
        uint256 timeElapsed = block.timestamp - userStake.lastClaimTime;
        uint256 baseReward = (userStake.amount * baseRewardRate * timeElapsed) / (365 days * 100);
        uint256 adjustedReward = (baseReward * tiers[userStake.tierId].rewardMultiplier) / 100;
        return (adjustedReward * uint256(price)) / 1e18; // Adjust by asset price
    }

    function claimRewards(uint256 stakeId) external {
        Stake storage userStake = stakes[msg.sender][stakeId];
        require(userStake.active, "Stake not active");
        uint256 reward = calculateRewards(msg.sender, stakeId);
        require(reward > 0, "No rewards available");
        require(rewardToken.balanceOf(address(this)) >= reward, "Insufficient reward funds");
        
        userStake.lastClaimTime = block.timestamp;
        totalRewardsDistributed += reward;
        require(rewardToken.transfer(msg.sender, reward), "Reward transfer failed");
        emit RewardsClaimed(msg.sender, stakeId, reward);
    }

    function unstake(uint256 stakeId) external {
        Stake storage userStake = stakes[msg.sender][stakeId];
        require(userStake.active, "Stake not active");
        require(block.timestamp >= userStake.startTime + tiers[userStake.tierId].lockPeriod, "Lock period not over");
        
        uint256 amount = userStake.amount;
        userStake.active = false;
        totalStaked -= amount;
        require(stakingToken.transfer(msg.sender, amount), "Transfer failed");
        emit Unstaked(msg.sender, stakeId, amount);
    }

    function updateBaseRewardRate(uint256 newRate) external onlyOwner {
        require(newRate <= 50, "Reward rate too high");
        baseRewardRate = newRate;
    }

    function fundRewards(uint256 amount) external onlyOwner {
        require(rewardToken.transferFrom(msg.sender, address(this), amount), "Funding failed");
    }
}