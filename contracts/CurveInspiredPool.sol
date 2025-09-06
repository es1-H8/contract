// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Curve-Inspired Stablecoin Pool with Chainlink Price Feeds
contract CurveInspiredPool is Ownable {
    using SafeMath for uint256;

    IERC20[] public tokens; // Array of stablecoins
    mapping(address => AggregatorV3Interface) public priceFeeds;
    uint256 public amplificationFactor = 100; // Curve A parameter
    uint256[] public reserves;
    uint256 public totalLiquidity;
    mapping(address => uint256) public liquidity;

    event Swap(address indexed user, uint256 tokenInIndex, uint256 tokenOutIndex, uint256 amountIn, uint256 amountOut);
    event LiquidityAdded(address indexed provider, uint256[] amounts, uint256 liquidityMinted);

    constructor(address[] memory _tokens, address[] memory _priceFeeds) Ownable(msg.sender) {
        require(_tokens.length == _priceFeeds.length, "Mismatched arrays");
        for (uint256 i = 0; i < _tokens.length; i++) {
            require(_tokens[i] != address(0), "Invalid token");
            require(_priceFeeds[i] != address(0), "Invalid price feed");
            tokens.push(IERC20(_tokens[i]));
            priceFeeds[_tokens[i]] = AggregatorV3Interface(_priceFeeds[i]);
        }
        reserves = new uint256[](_tokens.length);
    }

    function addLiquidity(uint256[] memory amounts) external {
        require(amounts.length == tokens.length, "Invalid amounts length");
        uint256 liquidityMinted = calculateLiquidityMinted(amounts);
        for (uint256 i = 0; i < tokens.length; i++) {
            require(amounts[i] > 0, "Invalid amount");
            require(tokens[i].transferFrom(msg.sender, address(this), amounts[i]), "Transfer failed");
            reserves[i] = reserves[i].add(amounts[i]);
        }
        liquidity[msg.sender] = liquidity[msg.sender].add(liquidityMinted);
        totalLiquidity = totalLiquidity.add(liquidityMinted);
        emit LiquidityAdded(msg.sender, amounts, liquidityMinted);
    }

    function calculateLiquidityMinted(uint256[] memory amounts) internal view returns (uint256) {
        if (totalLiquidity == 0) {
            uint256 product = 1;
            for (uint256 i = 0; i < amounts.length; i++) {
                product = product.mul(amounts[i]);
            }
            return product;
        }
        uint256 d = getD();
        return totalLiquidity.mul(d).div(getD());
    }

    function getD() internal view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < reserves.length; i++) {
            (, int256 price,,,) = priceFeeds[address(tokens[i])].latestRoundData();
            require(price > 0, "Invalid price data");
            sum = sum.add(reserves[i].mul(uint256(price)).div(1e18));
        }
        return sum.mul(amplificationFactor);
    }

    function swap(uint256 tokenInIndex, uint256 tokenOutIndex, uint256 amountIn) external returns (uint256 amountOut) {
        require(tokenInIndex < tokens.length && tokenOutIndex < tokens.length, "Invalid token index");
        require(amountIn > 0, "Invalid amount");
        (, int256 priceIn,,,) = priceFeeds[address(tokens[tokenInIndex])].latestRoundData();
        (, int256 priceOut,,,) = priceFeeds[address(tokens[tokenOutIndex])].latestRoundData();
        require(priceIn > 0 && priceOut > 0, "Invalid price data");
        amountOut = amountIn.mul(uint256(priceIn)).div(uint256(priceOut));
        amountOut = amountOut.mul(999).div(1000); // 0.1% fee
        require(tokens[tokenInIndex].transferFrom(msg.sender, address(this), amountIn), "Transfer in failed");
        require(tokens[tokenOutIndex].transfer(msg.sender, amountOut), "Transfer out failed");
        reserves[tokenInIndex] = reserves[tokenInIndex].add(amountIn);
        reserves[tokenOutIndex] = reserves[tokenOutIndex].sub(amountOut);
        emit Swap(msg.sender, tokenInIndex, tokenOutIndex, amountIn, amountOut);
        return amountOut;
    }
}