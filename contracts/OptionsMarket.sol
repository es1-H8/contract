// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Options Market with Chainlink Price Feeds
contract OptionsMarket is Ownable {
    using SafeMath for uint256;

    IERC20 public underlyingToken;
    AggregatorV3Interface public priceFeed;
    struct Option {
        address buyer;
        uint256 strikePrice;
        uint256 premium;
        uint256 expiry;
        bool isCall;
        bool exercised;
        uint256 amount;
    }
    mapping(uint256 => Option) public options;
    uint256 public optionCounter;

    event OptionCreated(uint256 indexed optionId, address buyer, uint256 strikePrice, bool isCall);
    event OptionExercised(uint256 indexed optionId, uint256 payout);

    constructor(address _underlyingToken, address _priceFeed) Ownable(msg.sender) {
        underlyingToken = IERC20(_underlyingToken);
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function buyOption(uint256 strikePrice, bool isCall, uint256 amount, uint256 duration) external {
        require(duration <= 30 days, "Duration too long");
        uint256 premium = calculatePremium(strikePrice, amount);
        require(underlyingToken.transferFrom(msg.sender, address(this), premium), "Premium payment failed");
        uint256 optionId = optionCounter++;
        options[optionId] = Option({
            buyer: msg.sender,
            strikePrice: strikePrice,
            premium: premium,
            expiry: block.timestamp + duration,
            isCall: isCall,
            exercised: false,
            amount: amount
        });
        emit OptionCreated(optionId, msg.sender, strikePrice, isCall);
    }

    function calculatePremium(uint256 strikePrice, uint256 amount) internal view returns (uint256) {
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        uint256 intrinsicValue = strikePrice > uint256(price) ? strikePrice.sub(uint256(price)) : 0;
        return intrinsicValue.add(amount.div(100)); // Simplified premium calculation
    }

    function exerciseOption(uint256 optionId) external {
        Option memory option = options[optionId];
        require(option.buyer == msg.sender, "Not option owner");
        require(!option.exercised, "Option already exercised");
        require(block.timestamp <= option.expiry, "Option expired");
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        uint256 payout;
        if (option.isCall && uint256(price) > option.strikePrice) {
            payout = option.amount.mul(uint256(price).sub(option.strikePrice)).div(1e18);
        } else if (!option.isCall && uint256(price) < option.strikePrice) {
            payout = option.amount.mul(option.strikePrice.sub(uint256(price))).div(1e18);
        }
        require(payout > 0, "Option out of money");
        options[optionId].exercised = true;
        require(underlyingToken.transfer(msg.sender, payout), "Payout failed");
        emit OptionExercised(optionId, payout);
    }
}