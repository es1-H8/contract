/**
 *Submitted for verification at BscScan.com on 2025-08-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MAXPRO is IERC20 {
    string public name = "MAXPRO";
    string public symbol = "MPT";
    uint8 public decimals = 18;
    uint256 private _totalSupply;
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    address public owner;
    address public maxproSystem;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier onlySystem() {
        require(msg.sender == maxproSystem, "Not authorized system");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function setMaxproSystem(address _system) external onlyOwner {
        require(_system != address(0), "Invalid system address");
        maxproSystem = _system;
    }
    
    function mint(address to, uint256 amount) external onlySystem {
        require(to != address(0), "Mint to zero address");
        _totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }
    
    function burn(address from, uint256 amount) external onlySystem {
        require(from != address(0), "Burn from zero address");
        require(_balances[from] >= amount, "Insufficient balance");
        _totalSupply -= amount;
        _balances[from] -= amount;
        emit Transfer(from, address(0), amount);
    }
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function allowance(address tokenOwner, address spender) public view override returns (uint256) {
        return _allowances[tokenOwner][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");
        
        _transfer(sender, recipient, amount);
        
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }
        
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfer from zero address");
        require(recipient != address(0), "Transfer to zero address");
        require(_balances[sender] >= amount, "Transfer amount exceeds balance");
        
        unchecked {
            _balances[sender] -= amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    
    function _approve(address tokenOwner, address spender, uint256 amount) internal {
        require(tokenOwner != address(0), "Approve from zero address");
        require(spender != address(0), "Approve to zero address");
        
        _allowances[tokenOwner][spender] = amount;
        emit Approval(tokenOwner, spender, amount);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    
    uint256 private _status;
    
    constructor() {
        _status = _NOT_ENTERED;
    }
    
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract MAXPROTOKEN is ReentrancyGuard {
    IERC20 public immutable USDT;
    MAXPRO public immutable maxproToken;
    
    // Constants
    uint256 private constant JOIN_FEE = 10 ether; // 10 USDT
    uint256 private constant ADMIN_FEE = 2 ether; // 2 USDT to admin
    uint256 private constant CONTRACT_FEE = 8 ether; // 8 USDT to contract
    uint256 private constant MAX_DIRECT_REFERRAL = 2;
    uint256 private constant REFERRAL_BONUS = 5 ether; // 5 tokens per referral
    uint256 private constant MIN_CLAIM_TOKENS = 10 ether; // 10 tokens minimum to claim
    uint256 private constant MIN_SELL_TOKENS = 10 ether; // 10 tokens minimum to sell
    uint256 private constant MAX_EARNING_CAP = 20 ether; // 20 USDT max earning
    uint256 private constant MAX_PRICE_CHANGE_PERCENT = 10; // 10% max price change
    uint256 public constant TIME_STEP = 60; // testnet - use 1 days for mainnet
    uint256 public constant MAX_SEARCH_ADDRESS = 600;
    
    // DEX Pool Balances (Virtual AMM)
    uint256 public usdtPoolBalance;  // USDT in the pool
    uint256 public tokenPoolBalance; // Tokens in the pool
    uint256 public lastPrice;        // Last recorded price
    
    // Daily minting rates per rank (0=Beginner, 1=Starter, etc.)
    uint256[] public DAILY_MINT_RATES = [1 ether, 2 ether, 5 ether, 10 ether, 20 ether, 30 ether, 40 ether, 50 ether];
    uint256[] public RANK_REQUIREMENTS = [0, 2, 4, 8, 16, 32, 64, 128];
    
    uint256 public currentID = 1;
    address public immutable adminWallet;
    uint256 public totalUsers;
    uint256 public totalTokensMinted;
    uint256 public totalTokensBurned;
    uint256 public totalTokensSold;
    bool private initialized;
    
    struct User {
        uint128 id;
        uint128 joinDate;
        uint128 lastMintTime;
        uint128 totalEarnedUSDT;
        uint128 originReferrer;
        uint128 mainReferrer;
        uint128 teamCount;
        uint128 pendingDailyTokens;
        uint128 referralTokens;
        uint128 currentSearchIndex;
        bool active;
        uint256[] referrals;
        uint256[] savedSearchArray;
    }
    
    mapping(address => User) public users;
    mapping(uint256 => address) public userList;
    
    event UserJoined(address indexed user, uint256 indexed id, uint256 referrer, uint256 timestamp);
    event TokensAccumulated(address indexed user, uint256 amount, uint256 rank, uint256 timestamp);
    event TokensClaimed(address indexed user, uint256 amount, uint256 timestamp);
    event TokensSold(address indexed user, uint256 tokenAmount, uint256 usdtAmount, uint256 newPrice, uint256 timestamp);
    event UserRejoined(address indexed user, uint256 timestamp);
    event ReferralBonus(address indexed referrer, address indexed referred, uint256 tokenAmount, uint256 timestamp);
    event UserDeactivated(address indexed user, uint256 totalEarned, uint256 timestamp);
    event PriceUpdated(uint256 oldPrice, uint256 newPrice, uint256 timestamp);
    event PoolUpdated(uint256 usdtPool, uint256 tokenPool, uint256 timestamp);
    
    constructor() {
        USDT = IERC20(0x55d398326f99059fF775485246999027B3197955); // BSC USDT
        adminWallet = 0x3Da7310861fbBdf5105ea6963A2C39d0Cb34a4Ff;   // Admin wallet
        maxproToken = new MAXPRO();
        maxproToken.setMaxproSystem(address(this));
        
        // Initialize with zero liquidity - price determined by contract balance / token supply
        usdtPoolBalance = 0;  // Not used anymore - keeping for compatibility
        tokenPoolBalance = 0; // Not used anymore - keeping for compatibility  
        lastPrice = 0;        // Will be calculated dynamically
        
        initializeAdmin();
    }
    
    function initializeAdmin() internal {
        require(!initialized, "Already initialized");
        
        users[adminWallet] = User({
            id: uint128(currentID),
            joinDate: uint128(block.timestamp),
            lastMintTime: uint128(block.timestamp),
            totalEarnedUSDT: 0,
            originReferrer: 0,
            mainReferrer: 0,
            teamCount: 0,
            pendingDailyTokens: 0,
            referralTokens: 0,
            currentSearchIndex: 0,
            active: true,
            referrals: new uint256[](0),
            savedSearchArray: new uint256[](0)
        });
        
        userList[currentID] = adminWallet;
        currentID++;
        totalUsers++;
        
        initialized = true;
    }
    
    function _autoUpdatePendingTokens(address userAddr) internal {
        User storage user = users[userAddr];
        
        if (user.joinDate == 0 || !user.active) return;
        
        uint256 rank = getUserRank(userAddr);
        if (rank == 999) return;
        
        uint256 timeElapsed = block.timestamp - user.lastMintTime;
        if (timeElapsed >= TIME_STEP) {
            uint256 daysPassed = timeElapsed / TIME_STEP;
            uint256 tokensToAccumulate = DAILY_MINT_RATES[rank] * daysPassed;
            
            if (tokensToAccumulate > 0) {
                user.pendingDailyTokens += uint128(tokensToAccumulate);
                user.lastMintTime = uint128(user.lastMintTime + (daysPassed * TIME_STEP));
                emit TokensAccumulated(userAddr, tokensToAccumulate, rank, block.timestamp);
            }
        }
    }
    
    function _updateUserAndUpline(address userAddr) internal {
        _autoUpdatePendingTokens(userAddr);
        
        address upline = userList[users[userAddr].mainReferrer];
        uint256 level = 0;
        while (upline != address(0) && level < 5) {
            _autoUpdatePendingTokens(upline);
            upline = userList[users[upline].mainReferrer];
            level++;
        }
    }
    
    function join(uint256 referrerId) external nonReentrant {
        require(users[msg.sender].joinDate == 0, "User already exists");
        require(users[userList[referrerId]].joinDate != 0, "Invalid referrer");
        require(USDT.allowance(msg.sender, address(this)) >= JOIN_FEE, "Insufficient USDT allowance");
        
        _autoUpdatePendingTokens(userList[referrerId]);
        
        require(USDT.transferFrom(msg.sender, adminWallet, ADMIN_FEE), "Admin fee transfer failed");
        require(USDT.transferFrom(msg.sender, address(this), CONTRACT_FEE), "Contract fee transfer failed");
        
        uint256 placementRef = referrerId;
        if (users[userList[referrerId]].referrals.length >= MAX_DIRECT_REFERRAL) {
            placementRef = _findFreeReferrer(referrerId);
        }
        
        users[msg.sender] = User({
            id: uint128(currentID),
            joinDate: uint128(block.timestamp),
            lastMintTime: uint128(block.timestamp),
            totalEarnedUSDT: 0,
            originReferrer: uint128(referrerId),
            mainReferrer: uint128(placementRef),
            teamCount: 0,
            pendingDailyTokens: 0,
            referralTokens: 0,
            currentSearchIndex: 0,
            active: true,
            referrals: new uint256[](0),
            savedSearchArray: new uint256[](0)
        });
        
        userList[currentID] = msg.sender;
        users[userList[placementRef]].referrals.push(currentID);
        _updateTeamCounts(msg.sender);
        
        if (referrerId != 1 && users[userList[referrerId]].active) {
            users[userList[referrerId]].referralTokens += uint128(REFERRAL_BONUS);
            emit ReferralBonus(userList[referrerId], msg.sender, REFERRAL_BONUS, block.timestamp);
        }
        
        currentID++;
        totalUsers++;
        
        emit UserJoined(msg.sender, users[msg.sender].id, referrerId, block.timestamp);
    }
    
    function rejoin() external nonReentrant {
        require(users[msg.sender].joinDate > 0, "User doesn't exist");
        require(!users[msg.sender].active, "User already active");
        require(USDT.allowance(msg.sender, address(this)) >= JOIN_FEE, "Insufficient USDT allowance");
        
        require(USDT.transferFrom(msg.sender, adminWallet, ADMIN_FEE), "Admin fee transfer failed");
        require(USDT.transferFrom(msg.sender, address(this), CONTRACT_FEE), "Contract fee transfer failed");
        
        users[msg.sender].active = true;
        users[msg.sender].totalEarnedUSDT = 0;
        users[msg.sender].lastMintTime = uint128(block.timestamp);
        users[msg.sender].pendingDailyTokens = 0;
        users[msg.sender].referralTokens = 0;
        
        uint256 originRef = users[msg.sender].originReferrer;
        if (originRef != 0 && originRef != 1 && users[userList[originRef]].active) {
            users[userList[originRef]].referralTokens += uint128(REFERRAL_BONUS);
            emit ReferralBonus(userList[originRef], msg.sender, REFERRAL_BONUS, block.timestamp);
        }
        
        emit UserRejoined(msg.sender, block.timestamp);
    }
    
    function claimDailyTokens() external nonReentrant {
        _autoUpdatePendingTokens(msg.sender);
        
        User storage user = users[msg.sender];
        require(user.joinDate > 0, "User doesn't exist");
        require(user.active, "User not active");
        require(user.pendingDailyTokens >= MIN_CLAIM_TOKENS, "Need at least 10 daily tokens to claim");
        
        uint256 tokensToMint = user.pendingDailyTokens;
        user.pendingDailyTokens = 0;
        
        maxproToken.mint(msg.sender, tokensToMint);
        totalTokensMinted += tokensToMint;
        
        emit TokensClaimed(msg.sender, tokensToMint, block.timestamp);
    }
    
    function claimReferralTokens() external nonReentrant {
        _autoUpdatePendingTokens(msg.sender);
        
        User storage user = users[msg.sender];
        require(user.joinDate > 0, "User doesn't exist");
        require(user.active, "User not active");
        require(user.referralTokens >= MIN_CLAIM_TOKENS, "Need at least 10 referral tokens to claim");
        
        uint256 tokensToMint = user.referralTokens;
        user.referralTokens = 0;
        
        maxproToken.mint(msg.sender, tokensToMint);
        totalTokensMinted += tokensToMint;
        
        emit TokensClaimed(msg.sender, tokensToMint, block.timestamp);
    }
    
    function sellTokens(uint256 tokenAmount) external nonReentrant {
        _autoUpdatePendingTokens(msg.sender);
        
        require(tokenAmount >= MIN_SELL_TOKENS, "Below minimum sell amount");
        require(maxproToken.balanceOf(msg.sender) >= tokenAmount, "Insufficient token balance");
        require(users[msg.sender].active, "User not active");
        
        uint256 totalSupply = maxproToken.totalSupply();
        require(totalSupply > 0, "No tokens exist yet");
        
        uint256 currentPrice = getTokenPrice();
        require(currentPrice > 0, "Price is zero - no USDT in contract");
        
        // Check price impact BEFORE calculating USDT amount
        (uint256 priceImpact, uint256 newPrice) = getPriceImpact(tokenAmount, true);
        require(priceImpact <= MAX_PRICE_CHANGE_PERCENT, "Sell amount would cause >10% price impact");
        
        uint256 usdtAmount = (tokenAmount * currentPrice) / 1 ether;
        
        require(users[msg.sender].totalEarnedUSDT + usdtAmount <= MAX_EARNING_CAP, "Exceeds earning cap");
        require(USDT.balanceOf(address(this)) >= usdtAmount, "Insufficient contract USDT");
        
        // Execute the trade: burn tokens and transfer USDT
        maxproToken.burn(msg.sender, tokenAmount);
        totalTokensBurned += tokenAmount;
        totalTokensSold++;
        
        require(USDT.transfer(msg.sender, usdtAmount), "USDT transfer failed");
        
        users[msg.sender].totalEarnedUSDT += uint128(usdtAmount);
        
        // Auto-deactivate if earning cap reached
        if (users[msg.sender].totalEarnedUSDT >= MAX_EARNING_CAP) {
            users[msg.sender].active = false;
            emit UserDeactivated(msg.sender, users[msg.sender].totalEarnedUSDT, block.timestamp);
        }
        
        emit TokensSold(msg.sender, tokenAmount, usdtAmount, newPrice, block.timestamp);
        emit PriceUpdated(currentPrice, newPrice, block.timestamp);
    }
    
    function _calculatePriceChangePercent(uint256 oldPrice, uint256 newPrice) internal pure returns (uint256) {
        if (oldPrice == 0) return 0;
        
        uint256 diff = oldPrice > newPrice ? oldPrice - newPrice : newPrice - oldPrice;
        return (diff * 100) / oldPrice;
    }
    
    function _updateTeamCounts(address userAddr) internal {
        address upline = userList[users[userAddr].mainReferrer];
        while (upline != address(0)) {
            users[upline].teamCount++;
            upline = userList[users[upline].mainReferrer];
        }
    }
    
    function _findFreeReferrer(uint256 _user) internal returns (uint256) {
        if (users[userList[_user]].referrals.length < MAX_DIRECT_REFERRAL) {
            return _user;
        }
        
        uint256[] storage referrals = users[userList[_user]].savedSearchArray;
        if (referrals.length == 0) {
            referrals.push(users[userList[_user]].referrals[0]);
            referrals.push(users[userList[_user]].referrals[1]);
        }
        
        for (uint256 i = users[userList[_user]].currentSearchIndex; i < MAX_SEARCH_ADDRESS && i < referrals.length; i++) {
            if (users[userList[referrals[i]]].referrals.length < MAX_DIRECT_REFERRAL) {
                return referrals[i];
            }
            
            if (users[userList[referrals[i]]].referrals.length == MAX_DIRECT_REFERRAL) {
                if (i < (MAX_SEARCH_ADDRESS / MAX_DIRECT_REFERRAL) - 1) {
                    referrals.push(users[userList[referrals[i]]].referrals[0]);
                    referrals.push(users[userList[referrals[i]]].referrals[1]);
                    users[userList[_user]].currentSearchIndex++;
                }
            }
        }
        
        revert("No free referrer found");
    }
    
    // View Functions
    function getTokenPrice() public view returns (uint256) {
        uint256 totalSupply = maxproToken.totalSupply();
        if (totalSupply == 0) return 0; // No tokens exist yet
        
        uint256 contractUSDTBalance = USDT.balanceOf(address(this));
        return (contractUSDTBalance * 1 ether) / totalSupply;
    }
    
    function getPoolBalances() public view returns (uint256 usdtPool, uint256 tokenPool) {
        return (usdtPoolBalance, tokenPoolBalance);
    }
    
    function getPriceImpact(uint256 tokenAmount, bool isSell) public view returns (uint256 priceImpact, uint256 newPrice) {
        uint256 totalSupply = maxproToken.totalSupply();
        uint256 contractUSDTBalance = USDT.balanceOf(address(this));
        
        if (totalSupply == 0) return (0, 0); // No tokens exist yet
        
        uint256 currentPrice = getTokenPrice();
        
        if (isSell) {
            // For selling: tokens get burned (reduce supply), USDT leaves contract
            uint256 usdtToRemove = (tokenAmount * currentPrice) / 1 ether;
            
            if (contractUSDTBalance <= usdtToRemove) return (100, 0); // Would drain contract
            if (totalSupply <= tokenAmount) return (100, 0); // Would burn all tokens
            
            uint256 newSupply = totalSupply - tokenAmount;
            uint256 newContractBalance = contractUSDTBalance - usdtToRemove;
            newPrice = (newContractBalance * 1 ether) / newSupply;
        } else {
            // For buying/claiming: tokens get minted (increase supply), USDT enters contract
            uint256 usdtToAdd = (tokenAmount * currentPrice) / 1 ether;
            uint256 newSupply = totalSupply + tokenAmount;
            uint256 newContractBalance = contractUSDTBalance + usdtToAdd;
            newPrice = (newContractBalance * 1 ether) / newSupply;
        }
        
        priceImpact = _calculatePriceChangePercent(currentPrice, newPrice);
    }

    // Helper function to calculate maximum sellable amount without exceeding 10% price impact
    function getMaxSellableAmount(address userAddr) public view returns (uint256 maxAmount) {
        uint256 userBalance = maxproToken.balanceOf(userAddr);
        if (userBalance == 0) return 0;
        
        // Binary search to find maximum sellable amount
        uint256 low = MIN_SELL_TOKENS;
        uint256 high = userBalance;
        maxAmount = 0;
        
        while (low <= high && low <= userBalance) {
            uint256 mid = (low + high) / 2;
            (uint256 priceImpact,) = getPriceImpact(mid, true);
            
            if (priceImpact <= MAX_PRICE_CHANGE_PERCENT) {
                maxAmount = mid;
                low = mid + 1;
            } else {
                if (mid == 0) break;
                high = mid - 1;
            }
        }
        
        return maxAmount;
    }
    
    // Check if user can sell a specific amount
    function canSellAmount(address userAddr, uint256 tokenAmount) public view returns (bool canSell, uint256 priceImpact, string memory reason) {
        if (!users[userAddr].active) {
            return (false, 0, "User not active");
        }
        
        if (maxproToken.balanceOf(userAddr) < tokenAmount) {
            return (false, 0, "Insufficient token balance");
        }
        
        if (tokenAmount < MIN_SELL_TOKENS) {
            return (false, 0, "Below minimum sell amount");
        }
        
        uint256 totalSupply = maxproToken.totalSupply();
        if (totalSupply == 0) {
            return (false, 0, "No tokens exist yet");
        }
        
        uint256 currentPrice = getTokenPrice();
        if (currentPrice == 0) {
            return (false, 0, "Price is zero - no USDT in contract");
        }
        
        (uint256 impact,) = getPriceImpact(tokenAmount, true);
        
        if (impact > MAX_PRICE_CHANGE_PERCENT) {
            return (false, impact, "Would cause >10% price impact");
        }
        
        uint256 usdtAmount = (tokenAmount * currentPrice) / 1 ether;
        
        if (users[userAddr].totalEarnedUSDT + usdtAmount > MAX_EARNING_CAP) {
            return (false, impact, "Would exceed earning cap");
        }
        
        if (USDT.balanceOf(address(this)) < usdtAmount) {
            return (false, impact, "Insufficient contract USDT");
        }
        
        return (true, impact, "Can sell");
    }
    
    function getUserRank(address userAddr) public view returns (uint256) {
        uint256 teamCount = users[userAddr].teamCount;
        
        for (uint256 i = RANK_REQUIREMENTS.length; i > 1; i--) {
            if (teamCount >= RANK_REQUIREMENTS[i - 1]) {
                return i - 1;
            }
        }
        
        return users[userAddr].joinDate > 0 ? 0 : 999;
    }
    
    function getUserRankName(address userAddr) public view returns (string memory) {
        uint256 rank = getUserRank(userAddr);
        if (rank == 0) return "Beginner";
        if (rank == 1) return "Starter";
        if (rank == 2) return "Bronze";
        if (rank == 3) return "Silver";
        if (rank == 4) return "Gold";
        if (rank == 5) return "Platinum";
        if (rank == 6) return "Diamond";
        if (rank == 7) return "Icon";
        return "No Rank";
    }
    
    function getCurrentDailyTokens(address userAddr) public view returns (uint256) {
        User memory user = users[userAddr];
        if (user.joinDate == 0 || !user.active) return 0;
        
        uint256 pendingDaily = user.pendingDailyTokens;
        uint256 rank = getUserRank(userAddr);
        
        if (rank != 999) {
            uint256 timeElapsed = block.timestamp - user.lastMintTime;
            if (timeElapsed >= TIME_STEP) {
                uint256 daysPassed = timeElapsed / TIME_STEP;
                pendingDaily += DAILY_MINT_RATES[rank] * daysPassed;
            }
        }
        
        return pendingDaily;
    }
    
    function getCurrentReferralTokens(address userAddr) public view returns (uint256) {
        return users[userAddr].referralTokens;
    }
    
    function canClaimDailyTokens(address userAddr) public view returns (bool) {
        return getCurrentDailyTokens(userAddr) >= MIN_CLAIM_TOKENS;
    }
    
    function canClaimReferralTokens(address userAddr) public view returns (bool) {
        User memory user = users[userAddr];
        return user.active && user.referralTokens >= MIN_CLAIM_TOKENS;
    }
    
    function getUserReferrals(address userAddr) public view returns (uint256[] memory) {
        return users[userAddr].referrals;
    }
    
    function getUserBasicStats(address userAddr) public view returns (
        uint256 id,
        uint256 rank,
        uint256 teamCount,
        uint256 totalEarnedUSDT,
        bool active
    ) {
        User memory user = users[userAddr];
        return (
            user.id,
            getUserRank(userAddr),
            user.teamCount,
            user.totalEarnedUSDT,
            user.active
        );
    }
    
    function getUserTokenStats(address userAddr) public view returns (
        uint256 walletTokenBalance,
        uint256 currentDailyTokens,
        uint256 currentReferralTokens,
        bool canClaimDaily,
        bool canClaimReferral,
        string memory rankName
    ) {
        return (
            maxproToken.balanceOf(userAddr),
            getCurrentDailyTokens(userAddr),
            getCurrentReferralTokens(userAddr),
            canClaimDailyTokens(userAddr),
            canClaimReferralTokens(userAddr),
            getUserRankName(userAddr)
        );
    }
    
    function getSystemStats() public view returns (
        uint256 _totalUsers,
        uint256 _contractUSDTBalance,
        uint256 _totalTokenSupply,
        uint256 _tokenPrice,
        uint256 _totalTokensMinted,
        uint256 _totalTokensBurned
    ) {
        return (
            totalUsers,
            USDT.balanceOf(address(this)),
            maxproToken.totalSupply(),
            getTokenPrice(),
            totalTokensMinted,
            totalTokensBurned
        );
    }
    
    function getCompleteSystemStats() public view returns (
        uint256 _totalUsers,
        uint256 _contractUSDTBalance,
        uint256 currentTokenPrice,
        uint256 totalSupply,
        uint256 totalMinted,
        uint256 totalBurned,
        uint256 totalSales
    ) {
        return (
            totalUsers,
            USDT.balanceOf(address(this)),
            getTokenPrice(),
            maxproToken.totalSupply(),
            totalTokensMinted,
            totalTokensBurned,
            totalTokensSold
        );
    }
    
    // Admin functions (with limited power)
    function emergencyWithdraw() external {
        require(msg.sender == adminWallet, "Only admin");
        uint256 balance = USDT.balanceOf(address(this));
        require(USDT.transfer(adminWallet, balance), "Transfer failed");
    }
}