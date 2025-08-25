// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SPP7Presale is Ownable, ReentrancyGuard {
    IERC20 public token;
    address public presaleWallet;
    uint256 public constant TOKEN_DECIMALS = 1e18;
    uint256 public constant TOKEN_USD_PRICE = 0.5 * 1e18; // 1 SPP7 = 0.5 USD
    uint256 public totalTokensForSale = 150_000_000 * TOKEN_DECIMALS;
    uint256 public totalSold;
    uint256 public totalSoldUsd;
    uint256 public minPurchase = 1e18; // $1
    bool public started = true; // Presale starts immediately

    struct CurrencyInfo {
        address tokenAddress;
        uint8 decimals;
        AggregatorV3Interface feedAddress;
        bool status;
    }
    mapping(address => CurrencyInfo) public payableTokens;

    event Purchased(address indexed user, uint256 volume, uint256 total);

    constructor(
        address _token,
        address _presaleWallet
    ) Ownable(msg.sender) {
        require(_token != address(0), "Invalid token address");
        require(_presaleWallet != address(0), "Invalid wallet address");
        
        token = IERC20(_token);
        presaleWallet = _presaleWallet;

        // BNB (native)
        payableTokens[address(0)] = CurrencyInfo(
            address(0),
            18,
            AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE), // BNB/USD
            true
        );
        // BTCB
        payableTokens[0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c] = CurrencyInfo(
            0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c,
            18,
            AggregatorV3Interface(0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf), // BTCB/USD
            true
        );
        // ETH
        payableTokens[0x2170Ed0880ac9A755fd29B2688956BD959F933F8] = CurrencyInfo(
            0x2170Ed0880ac9A755fd29B2688956BD959F933F8,
            18,
            AggregatorV3Interface(0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e), // ETH/USD
            true
        );
        // POL
        payableTokens[0xCC42724C6683B7E57334c4E856f4c9965ED682bD] = CurrencyInfo(
            0xCC42724C6683B7E57334c4E856f4c9965ED682bD,
            18,
            AggregatorV3Interface(0x081195B56674bb87b2B92F6D58F7c5f449aCE19d), // POL/USD
            true
        );
        // SOL
        payableTokens[0x570A5D26f7765Ecb712C0924E4De545B89fD43dF] = CurrencyInfo(
            0x570A5D26f7765Ecb712C0924E4De545B89fD43dF,
            18,
            AggregatorV3Interface(0x0E8a53DD9c13589df6382F13dA6B3Ec8F919B323), // SOL/USD
            true
        );
        // USDC
        payableTokens[0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d] = CurrencyInfo(
            0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d,
            18,
            AggregatorV3Interface(0x51597f405303C4377E36123cBc172b13269EA163), // USDC/USD
            true
        );
        // USDT
        payableTokens[0x55d398326f99059fF775485246999027B3197955] = CurrencyInfo(
            0x55d398326f99059fF775485246999027B3197955,
            18,
            AggregatorV3Interface(0xB97Ad0E74fa7d920791E90258A6E2085088b4320), // USDT/USD
            true
        );
        // XRP
        payableTokens[0x1D2F0da169ceB9fC7B3144628dB156f3F6c60dBE] = CurrencyInfo(
            0x1D2F0da169ceB9fC7B3144628dB156f3F6c60dBE,
            18,
            AggregatorV3Interface(0x93A67D414896A280bF8FFB3b389fE3686E014fda), // XRP/USD
            true
        );
    }

    receive() external payable nonReentrant {
        buyTokens(address(0), msg.value);
    }

    function estimatePurchase(address _token, uint256 amount) public view returns (uint256, uint256) {
        if (!payableTokens[_token].status) return (0, 0);
        uint256 currencyDecimal = 18 - payableTokens[_token].decimals;
        if (currencyDecimal > 0) {
            amount = amount * (10 ** currencyDecimal);
        }
        uint256 price = uint256(getLatestPrice(payableTokens[_token].feedAddress)); // Token price in USD with 8 decimals
        uint256 amtOut = (amount * price * TOKEN_DECIMALS) / TOKEN_USD_PRICE / (10 ** 8);
        uint256 totalUsd = (amount * price) / (10 ** 8);
        return (amtOut, totalUsd);
    }

    function buyTokens(address _token, uint256 _amount) public payable nonReentrant {
        require(started, "Presale not started");
        require(address(payableTokens[_token].feedAddress) != address(0), "Payable token is not valid");
        require(payableTokens[_token].status, "Payable token is not valid");
        
        (uint256 saleTokenAmt, uint256 totalUsd) = _token != address(0) ? estimatePurchase(_token, _amount) : estimatePurchase(address(0), msg.value);
        require(totalUsd >= minPurchase, "Minimum purchase amount not met");
        require(totalSold + saleTokenAmt <= totalTokensForSale, "Exceeds allocation");
        require(token.balanceOf(address(this)) >= saleTokenAmt, "Insufficient token balance in contract");

        if (_token != address(0)) {
            require(_amount > 0, "Amount must be greater than zero");
            require(IERC20(_token).transferFrom(msg.sender, presaleWallet, _amount), "Token transfer failed");
        } else {
            (bool success, ) = payable(presaleWallet).call{value: msg.value}("");
            require(success, "ETH transfer failed");
        }

        totalSold += saleTokenAmt;
        totalSoldUsd += totalUsd;
        require(token.transfer(msg.sender, saleTokenAmt), "Presale token transfer failed");
        emit Purchased(msg.sender, _amount, saleTokenAmt);
    }

    function getLatestPrice(AggregatorV3Interface _tokenAddress) public view returns (int256) {
        (, int256 price, , , ) = _tokenAddress.latestRoundData();
        require(price > 0, "Invalid price feed");
        return price;
    }

    function withdrawRemainingTokens() external onlyOwner nonReentrant {
        uint256 remaining = token.balanceOf(address(this));
        require(remaining > 0, "No tokens to withdraw");
        require(token.transfer(owner(), remaining), "Token withdrawal failed");
    }

    function emergencyWithdrawBNB() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "ETH withdrawal failed");
    }

    function updatePresaleWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "Invalid wallet");
        presaleWallet = newWallet;
    }

    function setMinPurchase(uint256 amount) external onlyOwner {
        minPurchase = amount;
    }

    function updatePayableTokens(address _tokens, uint8 _decimals, address _aggregator, bool _status) external onlyOwner {
        require(_tokens != address(0) || _status == false, "Invalid token address");
        payableTokens[_tokens] = CurrencyInfo(_tokens, _decimals, AggregatorV3Interface(_aggregator), _status);
    }

    function updateSaleStatus(bool _start) external onlyOwner {
        started = _start;
    }

    function withdrawAnyToken(address _tokenAddress, uint256 amt) external onlyOwner nonReentrant {
        uint256 bal = IERC20(_tokenAddress).balanceOf(address(this));
        require(bal >= amt, "Insufficient balance");
        require(IERC20(_tokenAddress).transfer(owner(), amt), "Token withdrawal failed");
    }
}