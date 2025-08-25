// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Dynamic Fee AMM with Chainlink Volatility Feed
contract DynamicFeeAMM is Ownable {
    using SafeMath for uint256;

    IERC20 public token0;
    IERC20 public token1;
    AggregatorV3Interface public volatilityFeed;
    uint256 public reserve0;
    uint256 public reserve1;
    uint256 public baseFee = 30; // 0.3%
    uint256 public maxFee = 100; // 1%
    uint256 public totalLiquidity;
    mapping(address => uint256) public liquidity;

    event Swap(address indexed user, uint256 amount0In, uint256 amount1Out);
    event LiquidityAdded(address indexed provider, uint256 amount0, uint256 amount1);

    constructor(address _token0, address _token1, address _volatilityFeed) Ownable(msg.sender) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
        volatilityFeed = AggregatorV3Interface(_volatilityFeed);
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function addLiquidity(uint256 amount0, uint256 amount1) external {
        require(amount0 > 0 && amount1 > 0, "Invalid amounts");
        uint256 liquidityMinted = totalLiquidity == 0
            ? sqrt(amount0.mul(amount1))
            : amount0.mul(totalLiquidity).div(reserve0);
        require(token0.transferFrom(msg.sender, address(this), amount0), "Token0 transfer failed");
        require(token1.transferFrom(msg.sender, address(this), amount1), "Token1 transfer failed");
        reserve0 = reserve0.add(amount0);
        reserve1 = reserve1.add(amount1);
        liquidity[msg.sender] = liquidity[msg.sender].add(liquidityMinted);
        totalLiquidity = totalLiquidity.add(liquidityMinted);
        emit LiquidityAdded(msg.sender, amount0, amount1);
    }

    function getDynamicFee() public view returns (uint256) {
        (, int256 volatility,,,) = volatilityFeed.latestRoundData();
        require(volatility > 0, "Invalid volatility data");
        uint256 fee = baseFee.add(uint256(volatility).mul(maxFee.sub(baseFee)).div(1e18));
        return fee > maxFee ? maxFee : fee;
    }

    function swap(uint256 amount0In, uint256 amount1In) external {
        require(amount0In > 0 || amount1In > 0, "Invalid input");
        uint256 fee = getDynamicFee();
        uint256 amountOut;
        if (amount0In > 0) {
            require(token0.transferFrom(msg.sender, address(this), amount0In), "Transfer failed");
            uint256 amount0AfterFee = amount0In.mul(10000 - fee).div(10000);
            amountOut = reserve1.mul(amount0AfterFee).div(reserve0.add(amount0AfterFee));
            require(token1.transfer(msg.sender, amountOut), "Transfer failed");
            reserve0 = reserve0.add(amount0In);
            reserve1 = reserve1.sub(amountOut);
        } else {
            require(token1.transferFrom(msg.sender, address(this), amount1In), "Transfer failed");
            uint256 amount1AfterFee = amount1In.mul(10000 - fee).div(10000);
            amountOut = reserve0.mul(amount1AfterFee).div(reserve1.add(amount1AfterFee));
            require(token0.transfer(msg.sender, amountOut), "Transfer failed");
            reserve1 = reserve1.add(amount1In);
            reserve0 = reserve0.sub(amountOut);
        }
        emit Swap(msg.sender, amount0In, amountOut);
    }
}