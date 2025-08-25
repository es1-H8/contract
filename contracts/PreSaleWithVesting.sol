pragma solidity ^0.8.20;

// SPDX-License-Identifier: MIT
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PreSaleWithVesting is Ownable {
    IERC20 public saleToken;
    AggregatorV3Interface public priceFeed;
    
    struct Purchase {
        uint256 amount;
        uint256 startTime;
        uint256 vestingDuration;
        uint256 claimed;
        bool active;
    }
    
    struct Tier {
        uint256 pricePerToken; // Price in USD (scaled by 1e18)
        uint256 maxPurchase;
        uint256 vestingDuration;
        uint256 totalSold;
    }
    
    mapping(address => mapping(uint256 => Purchase)) public purchases;
    mapping(address => uint256) public purchaseCount;
    mapping(uint256 => Tier) public tiers;
    uint256 public tierCount;
    uint256 public saleStartTime;
    uint256 public saleEndTime;
    uint256 public totalRaised;
    
    event TierAdded(uint256 indexed tierId, uint256 pricePerToken, uint256 maxPurchase, uint256 vestingDuration);
    event Purchased(address indexed buyer, uint256 purchaseId, uint256 amount, uint256 tierId);
    event Claimed(address indexed buyer, uint256 purchaseId, uint256 amount);

    constructor(address _saleToken, address _priceFeed, uint256 _saleDuration) Ownable(msg.sender) {
        saleToken = IERC20(_saleToken);
        priceFeed = AggregatorV3Interface(_priceFeed);
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDuration;
    }

    function addTier(uint256 pricePerToken, uint256 maxPurchase, uint256 vestingDuration) external onlyOwner {
        require(pricePerToken > 0, "Invalid price");
        require(maxPurchase > 0, "Invalid max purchase");
        require(vestingDuration >= 30 days, "Invalid vesting duration");
        tiers[tierCount] = Tier({
            pricePerToken: pricePerToken,
            maxPurchase: maxPurchase,
            vestingDuration: vestingDuration,
            totalSold: 0
        });
        emit TierAdded(tierCount, pricePerToken, maxPurchase, vestingDuration);
        tierCount++;
    }

    function purchase(uint256 tierId) external payable {
        require(tierId < tierCount, "Invalid tier");
        require(block.timestamp >= saleStartTime && block.timestamp <= saleEndTime, "Sale not active");
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        
        uint256 tokenAmount = (msg.value * uint256(price)) / tiers[tierId].pricePerToken;
        require(tokenAmount <= tiers[tierId].maxPurchase - tiers[tierId].totalSold, "Exceeds tier limit");
        require(saleToken.balanceOf(address(this)) >= tokenAmount, "Insufficient tokens");
        
        uint256 purchaseId = purchaseCount[msg.sender]++;
        purchases[msg.sender][purchaseId] = Purchase({
            amount: tokenAmount,
            startTime: block.timestamp,
            vestingDuration: tiers[tierId].vestingDuration,
            claimed: 0,
            active: true
        });
        
        tiers[tierId].totalSold = tiers[tierId].totalSold + tokenAmount;
        totalRaised = totalRaised + msg.value;
        emit Purchased(msg.sender, purchaseId, tokenAmount, tierId);
    }

    function claimTokens(uint256 purchaseId) external {
        Purchase storage userPurchase = purchases[msg.sender][purchaseId];
        require(userPurchase.active, "Purchase not active");
        uint256 elapsed = block.timestamp - userPurchase.startTime;
        uint256 vestedAmount = (userPurchase.amount * elapsed) / userPurchase.vestingDuration;
        uint256 claimable = vestedAmount - userPurchase.claimed;
        require(claimable > 0, "No tokens to claim");
        
        userPurchase.claimed = userPurchase.claimed + claimable;
        if (userPurchase.claimed >= userPurchase.amount) {
            userPurchase.active = false;
        }
        
        require(saleToken.transfer(msg.sender, claimable), "Transfer failed");
        emit Claimed(msg.sender, purchaseId, claimable);
    }

    function withdrawFunds(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(owner()).transfer(amount);
    }

    function endSale() external onlyOwner {
        require(block.timestamp > saleEndTime, "Sale still active");
        uint256 remainingTokens = saleToken.balanceOf(address(this));
        if (remainingTokens > 0) {
            require(saleToken.transfer(owner(), remainingTokens), "Token transfer failed");
        }
    }
}