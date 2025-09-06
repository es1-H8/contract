// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Governance Staking Pool with Chainlink Automation
contract GovernanceStakingPool is AutomationCompatible, Ownable {
    using SafeMath for uint256;

    IERC20 public stakingToken;
    IERC20 public rewardToken;
    
    struct Proposal {
        uint256 id;
        string description;
        uint256 startTime;
        uint256 endTime;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
    }
    
    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 lastClaimTime;
        bool active;
    }
    
    mapping(address => mapping(uint256 => Stake)) public stakes;
    mapping(address => uint256) public stakeCount;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => bool)) public voted;
    uint256 public proposalCount;
    uint256 public totalStaked;
    uint256 public rewardRate = 8; // 8% annual reward
    uint256 public lastRewardUpdate;
    uint256 public rewardInterval = 1 days;
    
    event Staked(address indexed user, uint256 stakeId, uint256 amount);
    event Unstaked(address indexed user, uint256 stakeId, uint256 amount);
    event ProposalCreated(uint256 indexed proposalId, string description, uint256 endTime);
    event Voted(address indexed voter, uint256 proposalId, bool support);
    event RewardsDistributed(address indexed user, uint256 stakeId, uint256 amount);

    constructor(address _stakingToken, address _rewardToken) Ownable(msg.sender) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        lastRewardUpdate = block.timestamp;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        uint256 stakeId = stakeCount[msg.sender]++;
        stakes[msg.sender][stakeId] = Stake({
            amount: amount,
            startTime: block.timestamp,
            lastClaimTime: block.timestamp,
            active: true
        });
        totalStaked = totalStaked.add(amount);
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        emit Staked(msg.sender, stakeId, amount);
    }

    function unstake(uint256 stakeId) external {
        Stake storage userStake = stakes[msg.sender][stakeId];
        require(userStake.active, "Stake not active");
        uint256 amount = userStake.amount;
        userStake.active = false;
        totalStaked = totalStaked.sub(amount);
        require(stakingToken.transfer(msg.sender, amount), "Transfer failed");
        emit Unstaked(msg.sender, stakeId, amount);
    }

    function createProposal(string calldata description, uint256 duration) external onlyOwner {
        require(duration >= 1 days && duration <= 7 days, "Invalid duration");
        uint256 proposalId = proposalCount++;
        proposals[proposalId] = Proposal({
            id: proposalId,
            description: description,
            startTime: block.timestamp,
            endTime: block.timestamp.add(duration),
            forVotes: 0,
            againstVotes: 0,
            executed: false
        });
        emit ProposalCreated(proposalId, description, block.timestamp.add(duration));
    }

    function vote(uint256 proposalId, bool support) external {
        require(proposalId < proposalCount, "Invalid proposal");
        require(block.timestamp <= proposals[proposalId].endTime, "Voting closed");
        require(!voted[msg.sender][proposalId], "Already voted");
        
        uint256 votingPower = 0;
        for (uint256 i = 0; i < stakeCount[msg.sender]; i++) {
            if (stakes[msg.sender][i].active) {
                votingPower = votingPower.add(stakes[msg.sender][i].amount);
            }
        }
        require(votingPower > 0, "No voting power");
        
        voted[msg.sender][proposalId] = true;
        if (support) {
            proposals[proposalId].forVotes = proposals[proposalId].forVotes.add(votingPower);
        } else {
            proposals[proposalId].againstVotes = proposals[proposalId].againstVotes.add(votingPower);
        }
        emit Voted(msg.sender, proposalId, support);
    }

    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = block.timestamp >= lastRewardUpdate + rewardInterval;
        performData = "";
        return (upkeepNeeded, performData);
    }

    function performUpkeep(bytes calldata) external override {
        require(block.timestamp >= lastRewardUpdate + rewardInterval, "Too soon");
        lastRewardUpdate = block.timestamp;
        
        for (uint256 i = 0; i < proposalCount; i++) {
            if (!proposals[i].executed && block.timestamp > proposals[i].endTime) {
                proposals[i].executed = true; // Simplified execution logic
            }
        }
        
        for (uint256 j = 0; j < stakeCount[msg.sender]; j++) {
            Stake storage userStake = stakes[msg.sender][j];
            if (userStake.active) {
                uint256 reward = userStake.amount.mul(rewardRate).mul(rewardInterval).div(365 days).div(100);
                require(rewardToken.balanceOf(address(this)) >= reward, "Insufficient reward funds");
                require(rewardToken.transfer(msg.sender, reward), "Reward transfer failed");
                userStake.lastClaimTime = block.timestamp;
                emit RewardsDistributed(msg.sender, j, reward);
            }
        }
    }
}