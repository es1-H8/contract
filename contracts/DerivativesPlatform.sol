// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Decentralized Derivatives Platform with Chainlink Automation
contract DerivativesPlatform is AutomationCompatible, Ownable {
    using SafeMath for uint256;

    AggregatorV3Interface internal priceFeed;
    IERC20 public settlementToken; // e.g., USDC
    struct Position {
        address trader;
        uint256 collateral;
        uint256 leverage;
        bool isLong;
        uint256 entryPrice;
        uint256 positionSize;
        uint256 openTime;
    }
    mapping(uint256 => Position) public positions;
    uint256 public positionCounter;
    uint256 public maintenanceMargin = 10; // 10% maintenance margin
    uint256 public maxLeverage = 10; // 10x max leverage
    uint256 public lastMaintenanceCheck;
    uint256 public maintenanceInterval = 1 hours;

    event PositionOpened(uint256 indexed positionId, address trader, uint256 collateral, bool isLong, uint256 leverage);
    event PositionClosed(uint256 indexed positionId, uint256 payout);

    constructor(address _priceFeed, address _settlementToken) Ownable() {
        priceFeed = AggregatorV3Interface(_priceFeed);
        settlementToken = IERC20(_settlementToken);
    }

    function openPosition(uint256 collateral, bool isLong, uint256 leverage) external {
        require(leverage <= maxLeverage, "Exceeds max leverage");
        require(settlementToken.transferFrom(msg.sender, address(this), collateral), "Collateral transfer failed");
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        uint256 positionId = positionCounter++;
        positions[positionId] = Position({
            trader: msg.sender,
            collateral: collateral,
            leverage: leverage,
            isLong: isLong,
            entryPrice: uint256(price),
            positionSize: collateral.mul(leverage),
            openTime: block.timestamp
        });
        emit PositionOpened(positionId, msg.sender, collateral, isLong, leverage);
    }

    function closePosition(uint256 positionId) external {
        Position memory pos = positions[positionId];
        require(pos.trader == msg.sender, "Not position owner");
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        uint256 currentPrice = uint256(price);
        uint256 profitOrLoss = pos.isLong
            ? pos.positionSize.mul(currentPrice.sub(pos.entryPrice)).div(pos.entryPrice)
            : pos.positionSize.mul(pos.entryPrice.sub(currentPrice)).div(pos.entryPrice);
        uint256 payout = pos.collateral.add(profitOrLoss);
        delete positions[positionId];
        require(settlementToken.transfer(msg.sender, payout), "Payout failed");
        emit PositionClosed(positionId, payout);
    }

    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = block.timestamp >= lastMaintenanceCheck + maintenanceInterval;
        performData = "";
        return (upkeepNeeded, performData);
    }

    function performUpkeep(bytes calldata) external override {
        require(block.timestamp >= lastMaintenanceCheck + maintenanceInterval, "Too soon");
        lastMaintenanceCheck = block.timestamp;
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        for (uint256 i = 1; i <= positionCounter; i++) {
            if (positions[i].trader != address(0)) {
                Position memory pos = positions[i];
                uint256 currentValue = pos.positionSize.mul(uint256(price)).div(pos.entryPrice);
                uint256 margin = pos.isLong
                    ? currentValue.sub(pos.positionSize)
                    : pos.positionSize.sub(currentValue);
                if (margin < pos.collateral.mul(maintenanceMargin).div(100)) {
                    // Liquidate position
                    delete positions[i];
                    require(settlementToken.transfer(pos.trader, pos.collateral.div(2)), "Liquidation refund failed");
                }
            }
        }
    }
}