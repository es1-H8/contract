// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Perpetual Futures Contract with Chainlink Automation
contract PerpetualFutures is AutomationCompatible, Ownable {
    using SafeMath for uint256;

    IERC20 public marginToken; // e.g., USDC
    AggregatorV3Interface public priceFeed;
    struct Position {
        address trader;
        uint256 collateral;
        uint256 leverage;
        bool isLong;
        uint256 entryPrice;
        uint256 positionSize;
        uint256 fundingRate; // Funding rate at position open
        uint256 openTime;
        bool active;
    }
    mapping(uint256 => Position) public positions;
    uint256 public positionCounter;
    uint256 public fundingInterval = 8 hours;
    uint256 public lastFundingUpdate;
    uint256 public fundingRate = 1; // 0.01% per funding interval
    uint256 public maintenanceMargin = 5; // 5% maintenance margin

    event PositionOpened(uint256 indexed positionId, address trader, uint256 collateral, bool isLong, uint256 leverage);
    event PositionClosed(uint256 indexed positionId, uint256 payout);
    event FundingPaid(address indexed trader, uint256 positionId, uint256 amount);

    constructor(address _priceFeed, address _marginToken) Ownable() {
        priceFeed = AggregatorV3Interface(_priceFeed);
        marginToken = IERC20(_marginToken);
    }

    function openPosition(uint256 collateral, bool isLong, uint256 leverage) external {
        require(leverage <= 20, "Exceeds max leverage");
        require(marginToken.transferFrom(msg.sender, address(this), collateral), "Collateral transfer failed");
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
            fundingRate: fundingRate,
            openTime: block.timestamp,
            active: true
        });
        emit PositionOpened(positionId, msg.sender, collateral, isLong, leverage);
    }

    function closePosition(uint256 positionId) external {
        Position memory pos = positions[positionId];
        require(pos.trader == msg.sender, "Not position owner");
        require(pos.active, "Position not active");
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        uint256 currentPrice = uint256(price);
        uint256 profitOrLoss = pos.isLong
            ? pos.positionSize.mul(currentPrice.sub(pos.entryPrice)).div(pos.entryPrice)
            : pos.positionSize.mul(pos.entryPrice.sub(currentPrice)).div(pos.entryPrice);
        uint256 fundingPayments = calculateFundingPayments(positionId);
        uint256 payout = pos.collateral.add(profitOrLoss).sub(fundingPayments);
        positions[positionId].active = false;
        require(marginToken.transfer(msg.sender, payout), "Payout failed");
        emit PositionClosed(positionId, payout);
    }

    function calculateFundingPayments(uint256 positionId) internal view returns (uint256) {
        Position memory pos = positions[positionId];
        uint256 intervals = block.timestamp.sub(pos.openTime).div(fundingInterval);
        return pos.positionSize.mul(pos.fundingRate).mul(intervals).div(10000);
    }

    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = block.timestamp >= lastFundingUpdate + fundingInterval;
        performData = "";
        return (upkeepNeeded, performData);
    }

    function performUpkeep(bytes calldata) external override {
        require(block.timestamp >= lastFundingUpdate + fundingInterval, "Too soon");
        lastFundingUpdate = block.timestamp;
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        for (uint256 i = 1; i <= positionCounter; i++) {
            if (positions[i].active) {
                Position memory pos = positions[i];
                uint256 currentValue = pos.positionSize.mul(uint256(price)).div(pos.entryPrice);
                uint256 margin = pos.isLong ? currentValue.sub(pos.positionSize) : pos.positionSize.sub(currentValue);
                if (margin < pos.collateral.mul(maintenanceMargin).div(100)) {
                    positions[i].active = false;
                    require(marginToken.transfer(pos.trader, pos.collateral.div(2)), "Liquidation refund failed");
                } else {
                    uint256 funding = calculateFundingPayments(i);
                    require(marginToken.transferFrom(pos.trader, address(this), funding), "Funding payment failed");
                    emit FundingPaid(pos.trader, i, funding);
                }
            }
        }
    }
}