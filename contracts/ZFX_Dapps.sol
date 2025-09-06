/**
 *Submitted for verification at BscScan.com on 2025-08-05
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
}

contract ZFX_Dapps {
    IERC20 public usdtToken;
    IERC20 public zfxToken;
    address public owner;
    
    uint256 public constant TOKEN_PRICE = 1800000000000000; 
    uint256 public constant TOKENS_FOR_SALE = 20000000 * 10**18; 
    uint256 public constant MIN_PURCHASE = 10 * 10**18; 
    uint256 public constant MAX_PURCHASE = 5000 * 10**18; 
    uint256 public constant HARD_CAP = 36000 * 10**18; 
    
    uint256 public totalRaised;
    uint256 public tokensSold;
    uint256 public participantsCount;
    bool public saleActive = true;
    
    mapping(address => uint256) public contributions;
    mapping(address => bool) public hasContributed;
    
    event TokensPurchased(address indexed buyer, uint256 usdtAmount, uint256 zfxAmount);
    event SaleFinalized(uint256 totalRaised, uint256 tokensSold);
    event SalePaused();
    event SaleResumed();
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    modifier whenSaleActive() {
        require(saleActive, "Sale is paused");
        require(tokensSold < TOKENS_FOR_SALE, "All tokens sold");
        require(totalRaised < HARD_CAP, "Hard cap reached");
        _;
    }
    
    constructor() {
        usdtToken = IERC20(0x55d398326f99059fF775485246999027B3197955);
        zfxToken = IERC20(0x249E91589bD022d70B2c09ECE52fDE7A1f7f9e72);
        owner = 0x103aEB3958c132Da90EB3aD156308edCA51b9CE9;
    }
    
    function buyTokens(uint256 usdtAmount) external whenSaleActive {
        require(usdtAmount >= MIN_PURCHASE, "Below minimum purchase");
        require(usdtAmount <= MAX_PURCHASE, "Exceeds maximum purchase");
        require(totalRaised + usdtAmount <= HARD_CAP, "Would exceed hard cap");
        
        uint256 zfxAmount = (usdtAmount * 10**18) / TOKEN_PRICE;
        
        require(tokensSold + zfxAmount <= TOKENS_FOR_SALE, "Would exceed tokens for sale");
        require(zfxToken.balanceOf(address(this)) >= zfxAmount, "Insufficient ZFX in contract");
        
        require(usdtToken.transferFrom(msg.sender, address(this), usdtAmount), "USDT transfer failed");
        require(zfxToken.transfer(msg.sender, zfxAmount), "ZFX transfer failed");
        
        totalRaised += usdtAmount;
        tokensSold += zfxAmount;
        contributions[msg.sender] += usdtAmount;
        
        if (!hasContributed[msg.sender]) {
            hasContributed[msg.sender] = true;
            participantsCount++;
        }
        
        emit TokensPurchased(msg.sender, usdtAmount, zfxAmount);
        
        if (totalRaised >= HARD_CAP || tokensSold >= TOKENS_FOR_SALE) {
            saleActive = false;
            emit SaleFinalized(totalRaised, tokensSold);
        }
    }
    
    function calculateTokenAmount(uint256 usdtAmount) public pure returns (uint256) {
        return (usdtAmount * 10**18) / TOKEN_PRICE;
    }
    
    function getTokenPrice() public pure returns (uint256) {
        return TOKEN_PRICE;
    }
    
    function getRemainingTokens() public view returns (uint256) {
        return TOKENS_FOR_SALE - tokensSold;
    }
    
    function getRemainingValue() public view returns (uint256) {
        return HARD_CAP - totalRaised;
    }
    
    function getSaleInfo() external view returns (
        uint256 tokensForSale,
        uint256 tokensSoldAmount,
        uint256 raisedAmount,
        uint256 participants,
        uint256 tokenPrice,
        uint256 minPurchase,
        uint256 maxPurchase,
        bool isActive
    ) {
        return (
            TOKENS_FOR_SALE,
            tokensSold,
            totalRaised,
            participantsCount,
            TOKEN_PRICE,
            MIN_PURCHASE,
            MAX_PURCHASE,
            saleActive && tokensSold < TOKENS_FOR_SALE && totalRaised < HARD_CAP
        );
    }
    
    function pauseSale() external onlyOwner {
        saleActive = false;
        emit SalePaused();
    }
    
    function resumeSale() external onlyOwner {
        require(tokensSold < TOKENS_FOR_SALE, "Cannot resume - all tokens sold");
        require(totalRaised < HARD_CAP, "Cannot resume - hard cap reached");
        saleActive = true;
        emit SaleResumed();
    }
    
    function withdrawUSDT() external onlyOwner {
        uint256 balance = usdtToken.balanceOf(address(this));
        require(balance > 0, "No USDT to withdraw");
        require(usdtToken.transfer(owner, balance), "USDT transfer failed");
    }
    
    function withdrawZFX() external onlyOwner {
        uint256 balance = zfxToken.balanceOf(address(this));
        require(balance > 0, "No ZFX to withdraw");
        require(zfxToken.transfer(owner, balance), "ZFX transfer failed");
    }
    
    function emergencyWithdraw(address token) external onlyOwner {
        require(token != address(0), "Invalid token address");
        IERC20 tokenContract = IERC20(token);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        require(tokenContract.transfer(owner, balance), "Token transfer failed");
    }
    
    function finalizeSale() external onlyOwner {
        saleActive = false;
        emit SaleFinalized(totalRaised, tokensSold);
    }
    
    function getSaleProgress() external view returns (uint256 percentSold, uint256 percentRaised) {
        percentSold = (tokensSold * 100) / TOKENS_FOR_SALE;
        percentRaised = (totalRaised * 100) / HARD_CAP;
    }
    
    function getUserContribution(address user) external view returns (uint256) {
        return contributions[user];
    }
}