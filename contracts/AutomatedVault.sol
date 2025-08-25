// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Automated Yield Vault with Chainlink Automation
contract AutomatedVault is AutomationCompatible, Ownable {
    using SafeMath for uint256;

    IERC20 public depositToken;
    struct Strategy {
        address protocol;
        uint256 apy;
        bool active;
        uint256 totalDeposits;
    }
    mapping(uint256 => Strategy) public strategies;
    mapping(address => mapping(uint256 => uint256)) public userDeposits;
    uint256 public strategyCounter;
    uint256 public lastRebalance;
    uint256 public rebalanceInterval = 1 days;
    uint256 public performanceFee = 20; // 2% fee

    event Deposit(address indexed user, uint256 strategyId, uint256 amount);
    event StrategyAdded(uint256 indexed strategyId, address protocol, uint256 apy);
    event Rebalanced(uint256 indexed strategyId, uint256 amount);

    constructor(address _depositToken) Ownable() {
        depositToken = IERC20(_depositToken);
    }

    function addStrategy(address protocol, uint256 apy) external onlyOwner {
        require(protocol != address(0), "Invalid protocol address");
        uint256 strategyId = strategyCounter++;
        strategies[strategyId] = Strategy({
            protocol: protocol,
            apy: apy,
            active: true,
            totalDeposits: 0
        });
        emit StrategyAdded(strategyId, protocol, apy);
    }

    function deposit(uint256 strategyId, uint256 amount) external {
        require(strategies[strategyId].active, "Inactive strategy");
        require(amount > 0, "Invalid amount");
        require(depositToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        require(depositToken.approve(strategies[strategyId].protocol, amount), "Approval failed");
        strategies[strategyId].totalDeposits = strategies[strategyId].totalDeposits.add(amount);
        userDeposits[msg.sender][strategyId] = userDeposits[msg.sender][strategyId].add(amount);
        emit Deposit(msg.sender, strategyId, amount);
    }

    function withdraw(uint256 strategyId, uint256 amount) external {
        require(userDeposits[msg.sender][strategyId] >= amount, "Insufficient balance");
        strategies[strategyId].totalDeposits = strategies[strategyId].totalDeposits.sub(amount);
        userDeposits[msg.sender][strategyId] = userDeposits[msg.sender][strategyId].sub(amount);
        require(depositToken.transfer(msg.sender, amount), "Transfer failed");
        emit Deposit(msg.sender, strategyId, amount);
    }

    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = block.timestamp >= lastRebalance + rebalanceInterval;
        performData = "";
        return (upkeepNeeded, performData);
    }

    function performUpkeep(bytes calldata) external override {
        require(block.timestamp >= lastRebalance + rebalanceInterval, "Too soon");
        lastRebalance = block.timestamp;
        uint256 bestApy = 0;
        uint256 bestStrategyId = 0;
        for (uint256 i = 0; i < strategyCounter; i++) {
            if (strategies[i].active && strategies[i].apy > bestApy) {
                bestApy = strategies[i].apy;
                bestStrategyId = i;
            }
        }
        if (bestStrategyId > 0) {
            for (uint256 i = 0; i < strategyCounter; i++) {
                if (i != bestStrategyId && strategies[i].totalDeposits > 0) {
                    uint256 amount = strategies[i].totalDeposits;
                    strategies[i].totalDeposits = 0;
                    strategies[bestStrategyId].totalDeposits = strategies[bestStrategyId].totalDeposits.add(amount);
                    emit Rebalanced(bestStrategyId, amount);
                }
            }
        }
    }

    function harvestFees(uint256 strategyId) external onlyOwner {
        uint256 profit = strategies[strategyId].totalDeposits.div(100); // Mock profit
        uint256 fee = profit.mul(performanceFee).div(1000);
        require(depositToken.transfer(owner(), fee), "Fee transfer failed");
    }
}