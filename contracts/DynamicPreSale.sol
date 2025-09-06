// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Dynamic Pre-Sale with Referral Rewards and Chainlink Price Feed
contract DynamicPreSale is Ownable {
    using SafeMath for uint256;

    IERC20 public saleToken;
    AggregatorV3Interface public priceFeed;
    
    struct Purchase {
        uint256 amount;
        uint256 paid;
        uint256 purchaseTime;
        address referrer;
        bool claimed;
    }
    
    struct Phase {
        uint256 pricePerToken; // Price in USD (scaled by 1e18)
        uint256 maxTokens;
        uint256 tokensSold;
        uint256 startTime;
        uint256 endTime;
    }
    
    mapping(address => mapping(uint256 => Purchase)) public purchases;
    mapping(address => uint256) public purchaseCount;
    mapping(address => uint256) public referralRewards;
    mapping(uint256 => Phase) public phases;
    uint256 public phaseCount;
    uint256 public referralRewardRate = 5; // 5% reward for referrers
    uint256 public totalRaised;
    
    event PhaseAdded(uint256 indexed phaseId, uint256 pricePerToken, uint256 maxTokens, uint256 startTime, uint256 endTime);
    event Purchased(address indexed buyer, uint256 purchaseId, uint256 amount, uint256 phaseId, address referrer);
    event ReferralRewardClaimed(address indexed referrer, uint256 amount);

    constructor(address _saleToken, address _priceFeed) Ownable(msg.sender) {
        saleToken = IERC20(_saleToken);
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function addPhase(uint256 pricePerToken, uint256 maxTokens, uint256 startTime, uint256 duration) external onlyOwner {
        require(pricePerToken > 0, "Invalid price");
        require(maxTokens > 0, "Invalid max tokens");
        require(startTime >= block.timestamp, "Invalid start time");
        phases[phaseCount] = Phase({
            pricePerToken: pricePerToken,
            maxTokens: maxTokens,
            tokensSold: 0,
            startTime: startTime,
            endTime: startTime.add(duration)
        });
        emit PhaseAdded(phaseCount, pricePerToken, maxTokens, startTime, startTime.add(duration));
        phaseCount++;
    }

    function purchase(uint256 phaseId, address referrer) external payable {
        require(phaseId < phaseCount, "Invalid phase");
        Phase memory phase = phases[phaseId];
        require(block.timestamp >= phase.startTime && block.timestamp <= phase.endTime, "Phase not active");
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        
        uint256 tokenAmount = msg.value.mul(uint256(price)).div(phase.pricePerToken);
        require(tokenAmount <= phase.maxTokens.sub(phase.tokensSold), "Exceeds phase limit");
        require(saleToken.balanceOf(address(this)) >= tokenAmount, "Insufficient tokens");
        
        uint256 purchaseId = purchaseCount[msg.sender]++;
        purchases[msg.sender][purchaseId] = Purchase({
            amount: tokenAmount,
            paid: msg.value,
            purchaseTime: block.timestamp,
            referrer: referrer == msg.sender || referrer == address(0) ? address(0) : referrer,
            claimed: false
        });
        
        phases[phaseId].tokensSold = phases[phaseId].tokensSold.add(tokenAmount);
        totalRaised = totalRaised.add(msg.value);
        
        if (purchases[msg.sender][purchaseId].referrer != address(0)) {
            uint256 referralReward = tokenAmount.mul(referralRewardRate).div(100);
            referralRewards[purchases[msg.sender][purchaseId].referrer] = referralRewards[purchases[msg.sender][purchaseId].referrer].add(referralReward);
        }
        
        emit Purchased(msg.sender, purchaseId, tokenAmount, phaseId, referrer);
    }

    function claimTokens(uint256 purchaseId) external {
        Purchase storage userPurchase = purchases[msg.sender][purchaseId];
        require(!userPurchase.claimed, "Tokens already claimed");
        userPurchase.claimed = true;
        require(saleToken.transfer(msg.sender, userPurchase.amount), "Transfer failed");
        emit Purchased(msg.sender, purchaseId, userPurchase.amount, 0, userPurchase.referrer);
    }

    function claimReferralRewards() external {
        uint256 reward = referralRewards[msg.sender];
        require(reward > 0, "No rewards available");
        referralRewards[msg.sender] = 0;
        require(saleToken.transfer(msg.sender, reward), "Reward transfer failed");
        emit ReferralRewardClaimed(msg.sender, reward);
    }

    function withdrawFunds(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(owner()).transfer(amount);
    }
}