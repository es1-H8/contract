/**
 *Submitted for verification at BscScan.com on 2025-08-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract VELTVesting {
    // Token contract
    IERC20 public immutable token;
    
    // Contract owner and creator
    address public immutable owner;
    address public immutable creator;
    
    // Distribution tracking
    uint256 public currentRound;
    uint256 public lastDistributionTime;
    uint256 public constant MAX_ROUNDS = 20;
    uint256 public constant QUARTER_DURATION = 90 days; // 3 months
    uint256 public constant TOTAL_TOKENS = 85_000_000_000 * 10**18; // 85 billion tokens (assuming 18 decimals)
    
    // Distribution addresses
    address public constant STAKING_REWARDS = 0x02a6ee7738D64dCA075306eaB340c03C8c5a4DDD;
    address public constant PRODUCT_DEVELOPMENT = 0xdB4dEC65A886Dca307552694f1844fEfae8120Ad;
    address public constant FOUNDERS_TEAM = 0x4B8320C9b601C5B8d8cabb554Cf8C561A511B0A6;
    address public constant MARKETING_PARTNERS = 0xBDceDAeb9c9Bc52506b4D3a9E2d4d70407C2f99B;
    address public constant ADVISOR_ALLOCATION = 0x59328733F55c991E9699beE2c5A15b1CB996217d;
    address public constant LIQUIDITY_RESERVE = 0x68601a38b998A0cac840137c7359545d9FaD045F;
    address public constant EMERGENCY_RESERVE = 0xEf880b9AC1778A0CdA31a66b9f4CcA04b0379273;
    
    // Per-quarter distribution amounts (total / 20 rounds)
    uint256 public constant STAKING_REWARDS_PER_QUARTER = 2_000_000_000 * 10**18; // 2B
    uint256 public constant PRODUCT_DEVELOPMENT_PER_QUARTER = 500_000_000 * 10**18; // 0.5B
    uint256 public constant FOUNDERS_TEAM_PER_QUARTER = 500_000_000 * 10**18; // 0.5B
    uint256 public constant MARKETING_PARTNERS_PER_QUARTER = 400_000_000 * 10**18; // 0.4B
    uint256 public constant ADVISOR_ALLOCATION_PER_QUARTER = 350_000_000 * 10**18; // 0.35B
    uint256 public constant LIQUIDITY_RESERVE_PER_QUARTER = 250_000_000 * 10**18; // 0.25B
    uint256 public constant EMERGENCY_RESERVE_PER_QUARTER = 250_000_000 * 10**18; // 0.25B
    
    // Total per quarter
    uint256 public constant TOTAL_PER_QUARTER = 4_250_000_000 * 10**18; // 4.25B
    
    // Contract state
    bool public tokensDeposited;
    bool public distributionStarted;
    
    // Events
    event TokensDeposited(uint256 amount, uint256 timestamp);
    event QuarterlyDistribution(uint256 round, uint256 timestamp);
    event DistributionComplete(uint256 totalRounds, uint256 timestamp);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyCreator() {
        require(msg.sender == creator, "Only creator can call this function");
        _;
    }
    
    modifier tokensLocked() {
        require(tokensDeposited, "Tokens not deposited yet");
        _;
    }
    
    constructor(address _token, address _creator) {
        require(_token != address(0), "Invalid token address");
        require(_creator != address(0), "Invalid creator address");
        
        token = IERC20(_token);
        owner = msg.sender;
        creator = _creator;
        currentRound = 0;
        lastDistributionTime = 0;
    }
    
    /**
     * @dev Owner deposits 85 billion tokens to lock them in the contract
     */
    function depositTokens() external onlyOwner {
        require(!tokensDeposited, "Tokens already deposited");
        require(token.transferFrom(msg.sender, address(this), TOTAL_TOKENS), "Token transfer failed");
        
        tokensDeposited = true;
        emit TokensDeposited(TOTAL_TOKENS, block.timestamp);
    }
    
    /**
     * @dev Creator triggers quarterly distribution
     */
    function distributeQuarterly() external onlyCreator tokensLocked {
        require(currentRound < MAX_ROUNDS, "All distributions completed");
        
        // Check if enough time has passed since last distribution (except for first distribution)
        if (distributionStarted) {
            require(
                block.timestamp >= lastDistributionTime + QUARTER_DURATION,
                "Quarter period not elapsed yet"
            );
        } else {
            distributionStarted = true;
        }
        
        // Increment round
        currentRound++;
        lastDistributionTime = block.timestamp;
        
        // Distribute tokens to all addresses
        require(token.transfer(STAKING_REWARDS, STAKING_REWARDS_PER_QUARTER), "Staking rewards transfer failed");
        require(token.transfer(PRODUCT_DEVELOPMENT, PRODUCT_DEVELOPMENT_PER_QUARTER), "Product development transfer failed");
        require(token.transfer(FOUNDERS_TEAM, FOUNDERS_TEAM_PER_QUARTER), "Founders team transfer failed");
        require(token.transfer(MARKETING_PARTNERS, MARKETING_PARTNERS_PER_QUARTER), "Marketing partners transfer failed");
        require(token.transfer(ADVISOR_ALLOCATION, ADVISOR_ALLOCATION_PER_QUARTER), "Advisor allocation transfer failed");
        require(token.transfer(LIQUIDITY_RESERVE, LIQUIDITY_RESERVE_PER_QUARTER), "Liquidity reserve transfer failed");
        require(token.transfer(EMERGENCY_RESERVE, EMERGENCY_RESERVE_PER_QUARTER), "Emergency reserve transfer failed");
        
        emit QuarterlyDistribution(currentRound, block.timestamp);
        
        // Check if all distributions are complete
        if (currentRound == MAX_ROUNDS) {
            emit DistributionComplete(currentRound, block.timestamp);
        }
    }
    
    /**
     * @dev Get contract information
     */
    function getContractInfo() external view returns (
        uint256 _currentRound,
        uint256 _maxRounds,
        uint256 _lastDistributionTime,
        uint256 _nextDistributionTime,
        bool _tokensDeposited,
        bool _distributionStarted,
        uint256 _contractBalance
    ) {
        uint256 nextDistTime = 0;
        if (distributionStarted && currentRound < MAX_ROUNDS) {
            nextDistTime = lastDistributionTime + QUARTER_DURATION;
        }
        
        return (
            currentRound,
            MAX_ROUNDS,
            lastDistributionTime,
            nextDistTime,
            tokensDeposited,
            distributionStarted,
            token.balanceOf(address(this))
        );
    }
    
    /**
     * @dev Get distribution addresses and amounts
     */
    function getDistributionInfo() external pure returns (
        address[7] memory addresses,
        uint256[7] memory quarterlyAmounts,
       uint96[7] memory totalAmounts
    ) {
        addresses = [
            STAKING_REWARDS,
            PRODUCT_DEVELOPMENT,
            FOUNDERS_TEAM,
            MARKETING_PARTNERS,
            ADVISOR_ALLOCATION,
            LIQUIDITY_RESERVE,
            EMERGENCY_RESERVE
        ];
        
        quarterlyAmounts = [
            STAKING_REWARDS_PER_QUARTER,
            PRODUCT_DEVELOPMENT_PER_QUARTER,
            FOUNDERS_TEAM_PER_QUARTER,
            MARKETING_PARTNERS_PER_QUARTER,
            ADVISOR_ALLOCATION_PER_QUARTER,
            LIQUIDITY_RESERVE_PER_QUARTER,
            EMERGENCY_RESERVE_PER_QUARTER
        ];
        
       totalAmounts = [
            uint96(40_000_000_000), // 40B 
            uint96(10_000_000_000), // 10B 
            uint96(10_000_000_000), // 10B 
            uint96(8_000_000_000),  // 8B 
            uint96(7_000_000_000),  // 7B 
            uint96(5_000_000_000),  // 5B 
            uint96(5_000_000_000)   // 5B
        ];
    }
    
  
    /**
     * @dev Get time remaining until next distribution can be called
     */
    function timeUntilNextDistribution() external view returns (uint256) {
        if (!distributionStarted || currentRound >= MAX_ROUNDS) {
            return 0;
        }
        
        uint256 nextDistTime = lastDistributionTime + QUARTER_DURATION;
        if (block.timestamp >= nextDistTime) {
            return 0;
        }
        
        return nextDistTime - block.timestamp;
    }
}