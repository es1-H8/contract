// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Yield Aggregator with Strategy Management and Chainlink Automation
contract YieldAggregator is AutomationCompatibleInterface, Ownable {
    struct Strategy {
        address protocol; // External protocol address
        uint256 apy; // Estimated APY (in basis points, e.g., 500 = 5%)
        bool active;
        uint256 totalDeposits;
    }

    IERC20 public immutable depositToken; // Token for deposits (e.g., DAI)
    mapping(uint256 => Strategy) public strategies;
    mapping(address => mapping(uint256 => uint256)) public userDeposits;
    uint256 public strategyCounter;
    uint256 public lastRebalance;
    uint256 public rebalanceInterval = 1 days;
    uint256 public constant MAX_PERFORMANCE_FEE = 200; // 20% max fee
    uint256 public performanceFee = 20; // 2% fee on profits (in basis points)

    event Deposit(address indexed user, uint256 indexed strategyId, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed strategyId, uint256 amount);
    event StrategyAdded(uint256 indexed strategyId, address protocol, uint256 apy);
    event StrategyUpdated(uint256 indexed strategyId, bool active);
    event Rebalance(uint256 indexed strategyId, uint256 amount);
    event FeesHarvested(uint256 indexed strategyId, uint256 feeAmount);

    constructor(address _depositToken) Ownable() {
        require(_depositToken != address(0), "Invalid token address");
        depositToken = IERC20(_depositToken);
    }

    // Add a new strategy
    function addStrategy(address protocol, uint256 apy) external onlyOwner {
        require(protocol != address(0), "Invalid protocol address");
        require(apy > 0, "APY must be greater than 0");

        uint256 strategyId = strategyCounter++;
        strategies[strategyId] = Strategy({
            protocol: protocol,
            apy: apy,
            active: true,
            totalDeposits: 0
        });
        emit StrategyAdded(strategyId, protocol, apy);
    }

    // Update strategy status
    function updateStrategyStatus(uint256 strategyId, bool active) external onlyOwner {
        require(strategyId < strategyCounter, "Invalid strategy ID");
        strategies[strategyId].active = active;
        emit StrategyUpdated(strategyId, active);
    }

    // Deposit tokens into a strategy
    function deposit(uint256 strategyId, uint256 amount) external {
        require(strategyId < strategyCounter, "Invalid strategy ID");
        require(strategies[strategyId].active, "Inactive strategy");
        require(amount > 0, "Deposit amount must be greater than 0");
        require(depositToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Approve tokens for the protocol (replace with actual protocol interaction)
        require(depositToken.approve(strategies[strategyId].protocol, amount), "Approval failed");

        strategies[strategyId].totalDeposits += amount;
        userDeposits[msg.sender][strategyId] += amount;
        emit Deposit(msg.sender, strategyId, amount);
    }

    // Withdraw tokens from a strategy
    function withdraw(uint256 strategyId, uint256 amount) external {
        require(strategyId < strategyCounter, "Invalid strategy ID");
        require(amount > 0, "Withdraw amount must be greater than 0");
        require(userDeposits[msg.sender][strategyId] >= amount, "Insufficient balance");

        // Simulate external protocol withdrawal (replace with actual protocol interaction)
        strategies[strategyId].totalDeposits -= amount;
        userDeposits[msg.sender][strategyId] -= amount;
        require(depositToken.transfer(msg.sender, amount), "Transfer failed");

        emit Withdraw(msg.sender, strategyId, amount);
    }

    // Check if upkeep is needed (Chainlink Automation)
    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = block.timestamp >= lastRebalance + rebalanceInterval;
        performData = "";
        return (upkeepNeeded, performData);
    }

    // Perform rebalance to the strategy with the highest APY
    function performUpkeep(bytes calldata /* performData */) external override {
        require(block.timestamp >= lastRebalance + rebalanceInterval, "Too soon for rebalance");
        lastRebalance = block.timestamp;

        if (strategyCounter == 0) return; // No strategies to rebalance

        uint256 bestApy = 0;
        uint256 bestStrategyId = 0;
        bool foundActiveStrategy = false;

        // Find the active strategy with the highest APY
        for (uint256 i = 0; i < strategyCounter; i++) {
            if (strategies[i].active && strategies[i].apy > bestApy) {
                bestApy = strategies[i].apy;
                bestStrategyId = i;
                foundActiveStrategy = true;
            }
        }

        if (foundActiveStrategy) {
            // Reallocate funds to the best strategy
            for (uint256 i = 0; i < strategyCounter; i++) {
                if (i != bestStrategyId && strategies[i].active && strategies[i].totalDeposits > 0) {
                    uint256 amount = strategies[i].totalDeposits;
                    strategies[i].totalDeposits = 0;
                    strategies[bestStrategyId].totalDeposits += amount;
                    // Simulate fund reallocation (replace with actual protocol interaction)
                    emit Rebalance(bestStrategyId, amount);
                }
            }
        }
    }

    // Harvest performance fees from a strategy
    function harvestFees(uint256 strategyId) external onlyOwner {
        require(strategyId < strategyCounter, "Invalid strategy ID");

        // Simulate profit calculation (replace with actual protocol interaction)
        uint256 profit = strategies[strategyId].totalDeposits / 100; // Mock 1% profit
        uint256 fee = (profit * performanceFee) / 1000; // Fee in basis points
        require(fee > 0, "No fees to harvest");
        require(depositToken.transfer(owner(), fee), "Fee transfer failed");

        // Adjust total deposits to reflect fee withdrawal
        strategies[strategyId].totalDeposits -= fee;
        emit FeesHarvested(strategyId, fee);
    }

    // Update performance fee (in basis points, e.g., 20 = 2%)
    function setPerformanceFee(uint256 newFee) external onlyOwner {
        require(newFee <= MAX_PERFORMANCE_FEE, "Fee exceeds maximum");
        performanceFee = newFee;
    }

    // Update rebalance interval
    function setRebalanceInterval(uint256 newInterval) external onlyOwner {
        require(newInterval >= 1 hours, "Interval too short");
        rebalanceInterval = newInterval;
    }
}