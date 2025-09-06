/**
 *Submitted for verification at BscScan.com on 2025-08-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract VNSTStaking {
    function _add(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            uint256 c = a + b;
            require(c >= a, "Math: Add overflow");
            return c;
        }
    }
    
    function _sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Math: Sub underflow");
        return a - b;
    }
    
    function _mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        unchecked {
            uint256 c = a * b;
            require(c / a == b, "Math: Mul overflow");
            return c;
        }
    }
    
    function _div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "Math: Div by zero");
        return a / b;
    }

    bool private _locked;
    modifier nonReentrant() {
        require(!_locked, "Reentrant call");
        _locked = true;
        _;
        _locked = false;
    }

    address public owner;
    bool public paused;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier whenNotPaused() {
        require(!paused, "Contract paused");
        _;
    }

    modifier whenNotEmergencyStopped() {
        require(!emergencyStop, "Contract emergency stopped");
        _;
    }

    modifier validPercentages() {
        for(uint i=0; i<5; i++) {
            if(directRewardPercents[i] > 10) {
                emit PercentageCheckFailed(msg.sender, "Direct reward too high");
                revert("Direct reward too high");
            }
        }
        _;
    }

    uint256 public totalUsers;
    uint256 public totalStakedInContract;
    uint256 public totalActiveStake;
    uint256 public totalVNTWithdrawn;
    uint256 public totalStakingTransactions;
    bool public emergencyStop;


    IERC20 public vnstToken;
    IERC20 public vntToken;
    IERC20 public usdtToken;

    uint256 public constant SECONDS_PER_DAY = 86400;
    uint256 public constant DAYS_IN_YEAR = 365;
    uint256 public minStakeAmount = 100 ether;
    uint256 public maxStakeAmount = 10000 ether;
    uint256 public withdrawFee = 5; 
    uint256 public constant FIXED_APY = 200;
    uint256[5] public directRewardPercents = [5, 3, 2, 1, 1]; 
    uint256 public maxManualStakePerUser = 10000 ether;
    uint256 public minVNTWithdraw = 10 ether; 

    address public vnstStakingWallet;
    address public vntRewardWallet;
    address public usdtRewardWallet;
    address public vnstAutoStakeWallet;
    address public feeWallet;

    struct Stake {
        uint256 amount;
        uint256 startDay;
        uint256 lastClaimDay;
        bool isActive;
    }
    
    struct WithdrawInfo {
        uint256 amount;
        uint256 timestamp;
        bool isCompleted;
    }

    struct User {
        address referrer;
        uint256 totalManualStaked;
        uint256 totalStaked;
        uint256 totalClaimed;
        uint256 lastClaimTimestamp;
        uint256[5] levelDeposits;
        uint256 referralCount;
        
    }

    mapping(address => User) public users;
    mapping(address => Stake[]) public userStakes;
    mapping(address => bool) public blacklisted;
    mapping(address => bool) public whitelisted;
    mapping(address => mapping(uint256 => uint256)) public referralCountByLevel;
    address public defaultReferral;
    mapping(address => mapping(uint256 => address[])) public teamUsers;
    mapping(address => mapping(address => uint256)) public userLevelDeposit; 
    mapping(address => mapping(uint256 => bool)) public checkLevel;
    mapping(address => uint256) public validDeposit;
    mapping(address => mapping(address => bool)) public countedAsValidReferral;
    mapping(address => uint256) public curUserLevel;
    mapping(address => WithdrawInfo[]) public withdrawHistory;

    event Staked(address indexed user, uint256 amount, address referrer);
    event RewardClaimed(address indexed user, uint256 vntAmount);
    event ReferralReward(address indexed referrer, address indexed user, uint256 level, uint256 amount);
    event LevelDepositUpdated(address indexed referrer, uint256 level, uint256 amount);
    event ContractPaused(bool paused);
    event EmergencyStopped(address indexed by, bool status);
    event MinWithdrawToggled(bool status);
    event PercentageCheckFailed(address user, string message);
    event MinWithdrawAmountsChanged(uint256 minVNT);
    event DirectRewardPercentsChanged(uint256[5] newPercents);
    event LevelUnlocked(address indexed user, uint256 level);
    event TeamStakeUpdated(address indexed user, uint256 totalTeamStake);
    event NewUserJoined(address indexed user, uint256 totalUsers);
    event StakeUpdated(uint256 totalStaked, uint256 activeStake);
    event VNTWithdrawn(address indexed user, uint256 amount, uint256 totalWithdrawn);
    event MaxManualStakeLimitUpdated(uint256 newLimit);
    event USDTTransfer(address indexed to, uint256 amount);
    event VNTTransfer(address indexed to, uint256 amount, uint256 fee);
    event ReferralAdded(address indexed referrer, address indexed newUser, uint256 timestamp);
    event ReferralCommission(address indexed referrer, uint256 level, uint256 amount, address token);
    event UserStatusChanged(address indexed user, string statusType, bool status);
    
    constructor(
        address _vnstToken,
        address _vntToken,
        address _usdtToken,
        address _vnstStakingWallet,
        address _vntRewardWallet,
        address _usdtRewardWallet,
        address _vnstAutoStakeWallet,
        address _feeWallet
    ) {
        owner = msg.sender;
        defaultReferral = msg.sender;
        
        vnstToken = IERC20(_vnstToken);
        vntToken = IERC20(_vntToken);
        usdtToken = IERC20(_usdtToken);
        
        vnstStakingWallet = _vnstStakingWallet;
        vntRewardWallet = _vntRewardWallet;
        usdtRewardWallet = _usdtRewardWallet;
        vnstAutoStakeWallet = _vnstAutoStakeWallet;
        feeWallet = _feeWallet;
    }

    function _currentDay() internal view returns (uint256) {
        return block.timestamp / SECONDS_PER_DAY;
    }

    function _calculatePendingVNTRewards(address userAddress) internal returns (uint256) {
        Stake[] storage stakes = userStakes[userAddress];
        uint256 currentDay = _currentDay();
        uint256 vntRewards;
    
        for (uint256 i = 0; i < stakes.length; i++) {
            Stake storage stakeInfo = stakes[i];
            if (!stakeInfo.isActive) continue;
        
            uint256 daysStaked = _sub(currentDay, stakeInfo.startDay);
            if (daysStaked > DAYS_IN_YEAR) daysStaked = DAYS_IN_YEAR;
        
            uint256 daysClaimed = _sub(stakeInfo.lastClaimDay, stakeInfo.startDay);
            if (daysStaked > daysClaimed) {
                uint256 unclaimedDays = _sub(daysStaked, daysClaimed);
                vntRewards += (_mul(stakeInfo.amount, 200) * unclaimedDays) / (100 * DAYS_IN_YEAR);
                stakeInfo.lastClaimDay = currentDay;
            }
        }
        return vntRewards;
    }

    function _distributeReferralRewards(address userAddress, uint256 amount) internal {
        User storage user = users[userAddress];
        address referrer = user.referrer;
        
        for (uint256 i = 0; i < 5 && referrer != address(0); i++) {
            users[referrer].levelDeposits[i] += amount;
            emit LevelDepositUpdated(referrer, i, amount);
            
            if (i == 0) {
                uint256 autoStakeAmount = _mul(amount, directRewardPercents[i]) / 100;
                if (vnstToken.balanceOf(vnstAutoStakeWallet) >= autoStakeAmount) {
                    require(vnstToken.transferFrom(vnstAutoStakeWallet, vnstStakingWallet, autoStakeAmount), "Auto-stake failed");
                    validDeposit[referrer] += 1;
                    countedAsValidReferral[referrer][userAddress] = true;

                    users[referrer].totalStaked += autoStakeAmount;

                    userStakes[referrer].push(Stake({
                        amount: autoStakeAmount,
                        startDay: _currentDay(),
                        lastClaimDay: _currentDay(),
                        isActive: true
                    }));
                    emit ReferralReward(referrer, userAddress, i+1, autoStakeAmount);
                }
            }
            
            if (i >= 1 && i < 5) {
                uint256 usdtReward = _mul(_mul(amount, 0.1 ether) / 1 ether, directRewardPercents[i]) / 100;
                require(
                    usdtToken.allowance(usdtRewardWallet, address(this)) >= usdtReward,
                    "Insufficient USDT allowance from reward wallet"
                );
                if (usdtToken.balanceOf(usdtRewardWallet) >= usdtReward) {
                    require(usdtToken.transferFrom(usdtRewardWallet, referrer, usdtReward), "USDT reward failed");
                    emit ReferralReward(referrer, userAddress, i+1, usdtReward);
                    emit USDTTransfer(referrer, usdtReward);
                }
            }
            
            if (referrer == defaultReferral) break;
            referrer = users[referrer].referrer;
        }
    }

    function _updateReferralTree(address referrer) internal {
        for (uint256 i = 0; i < 5 && referrer != address(0); i++) {
            referralCountByLevel[referrer][i]++;
            users[referrer].referralCount++;
            _updateUserLevel(referrer);
            if (referrer == defaultReferral) break;
            referrer = users[referrer].referrer;
        }
    }

    function _updateUserLevel(address _user) internal {
        for (uint256 level = 1; level <= 5; level++) {
            if (!checkLevel[_user][level] && referralCountByLevel[_user][level-1] >= 2) {
                checkLevel[_user][level] = true;
                curUserLevel[_user] = level;
                emit LevelUnlocked(_user, level);
            }
        }
    }

    function stake(uint256 amount, address referrer) external nonReentrant whenNotPaused whenNotEmergencyStopped {
        require(!blacklisted[msg.sender], "Blacklisted");
        require(amount >= minStakeAmount && amount <= maxStakeAmount, "Invalid amount");
        require(
            users[msg.sender].totalManualStaked + amount <= maxManualStakePerUser,
            "You have reached max manual stake limit (10,000 VNST)"
        );
        require(vnstToken.transferFrom(msg.sender, vnstStakingWallet, amount), "Transfer failed");

        User storage user = users[msg.sender];
        
        if (user.referrer == address(0)) {
            if (referrer == address(0)) {
                referrer = defaultReferral;
            } else {
                require(referrer != msg.sender, "Self-referral");
                require(users[referrer].referrer != address(0) || referrer == defaultReferral, "Invalid referrer");
            }
            user.referrer = referrer;
            emit ReferralAdded(referrer, msg.sender, block.timestamp);
            _updateReferralTree(referrer);
            totalUsers++;
        }

        userStakes[msg.sender].push(Stake({
            amount: amount,
            startDay: _currentDay(),
            lastClaimDay: _currentDay(),
            isActive: true
        }));
        users[msg.sender].totalManualStaked += amount;
        user.totalStaked += amount;

        totalStakedInContract += amount;
        totalActiveStake += amount;
        totalStakingTransactions++;

        _distributeReferralRewards(msg.sender, amount);

        emit Staked(msg.sender, amount, user.referrer);
        emit TeamStakeUpdated(msg.sender, getTotalTeamStake(msg.sender));
    }

    function claimVNTRewards() external nonReentrant whenNotPaused whenNotEmergencyStopped {
        require(!blacklisted[msg.sender], "Blacklisted");
    
        uint256 vntRewards = _calculatePendingVNTRewards(msg.sender);
    
        require(vntRewards >= minVNTWithdraw, "Minimum VNT withdrawal not met");
    
        uint256 vntFee = _mul(vntRewards, withdrawFee) / 100;
        totalVNTWithdrawn += (vntRewards - vntFee);
        require(vntToken.transferFrom(vntRewardWallet, msg.sender, vntRewards - vntFee), "VNT transfer failed");
        require(vntToken.transferFrom(vntRewardWallet, feeWallet, vntFee), "VNT fee transfer failed");

        emit VNTTransfer(msg.sender, vntRewards - vntFee, vntFee);
        emit VNTTransfer(feeWallet, vntFee, 0);

    }
    
    function claimAllRewards() external nonReentrant whenNotPaused whenNotEmergencyStopped {
        require(!blacklisted[msg.sender], "Blacklisted");
        uint256 vntRewards = _calculatePendingVNTRewards(msg.sender);
        require(vntRewards >= minVNTWithdraw, "Minimum not met");

        uint256 vntFee = (vntRewards * withdrawFee) / 100;
        require(vntToken.transferFrom(vntRewardWallet, msg.sender, vntRewards - vntFee), "VNT transfer failed");
        require(vntToken.transferFrom(vntRewardWallet, feeWallet, vntFee), "VNT fee failed");
    
        emit RewardClaimed(msg.sender, vntRewards);
    }

    function getPendingRewards(address userAddress) public view returns (uint256 vntRewards) {
        Stake[] storage stakes = userStakes[userAddress];
        uint256 currentDay = _currentDay();
    
        for (uint256 i = 0; i < stakes.length; i++) {
            Stake storage stakeInfo = stakes[i];
            if (!stakeInfo.isActive) continue;
        
            uint256 daysStaked = _sub(currentDay, stakeInfo.startDay);
            if (daysStaked > DAYS_IN_YEAR) daysStaked = DAYS_IN_YEAR;
        
            uint256 daysClaimed = _sub(stakeInfo.lastClaimDay, stakeInfo.startDay);
            if (daysStaked > daysClaimed) {
                uint256 unclaimedDays = _sub(daysStaked, daysClaimed);
                vntRewards += (_mul(stakeInfo.amount, 2) * unclaimedDays) / DAYS_IN_YEAR;
            }
        }
    }

    function getReferralCount(address user, uint256 level) public view returns (uint256) {
        return referralCountByLevel[user][level];
    }

    function getUserStakesCount(address user) public view returns (uint256) {
        return userStakes[user].length;
    }

    function getTeamUsers(address _user, uint256 _level) public view returns (address[] memory) {
        return teamUsers[_user][_level];
    }

    function getTotalTeamStake(address _user) public view returns (uint256) {
        uint256 total;
        address[] memory team;
    
        for (uint256 level = 0; level < 5; level++) {
            team = teamUsers[_user][level];
            for (uint256 i = 0; i < team.length; i++) {
                total += getTotalStaked(team[i]);
            }
        }
        return total;
    }

    function getLevelDetails(address _user) public view returns (
        uint256 currentLevel,
        uint256[] memory levelDeposits,
        bool[] memory levelsAchieved
    ) {
        currentLevel = curUserLevel[_user];
        levelDeposits = new uint256[](5);
        levelsAchieved = new bool[](5);
    
        for(uint256 i=0; i<5; i++) {
            levelDeposits[i] = users[_user].levelDeposits[i];
            levelsAchieved[i] = checkLevel[_user][i+1];
        }
    }

    function getTotalTeamStakeByLevel(address _user, uint256 _level) public view returns (uint256) {
        uint256 total;
        address[] memory team = teamUsers[_user][_level];
        for (uint256 i = 0; i < team.length; i++) {
            total += getTotalStaked(team[i]);
        }
        return total;
    }

    function isLevelUnlocked(address _user, uint256 _level) public view returns (bool) {
        require(_level >= 1 && _level <= 5, "Invalid level");
        return checkLevel[_user][_level];
    }

    function getStakeHistory(address _user) public view returns (
        uint256[] memory amounts,
        uint256[] memory startDays,
        bool[] memory isActive
    ) {
        uint256 count = userStakes[_user].length;
        amounts = new uint256[](count);
        startDays = new uint256[](count);
        isActive = new bool[](count);
    
        for(uint256 i=0; i<count; i++) {
            Stake storage stakeInfo = userStakes[_user][i];
            amounts[i] = stakeInfo.amount;
            startDays[i] = stakeInfo.startDay;
            isActive[i] = stakeInfo.isActive;
        }
    }

    function getStakeDays(address _user, uint256 _stakeIndex) public view returns (uint256) {
        require(_stakeIndex < userStakes[_user].length, "Invalid stake index");
        Stake memory stakeInfo = userStakes[_user][_stakeIndex];
        return _sub(_currentDay(), stakeInfo.startDay);
    }

    function getWithdrawHistory(address _user) public view returns (
        uint256[] memory amounts,
        uint256[] memory timestamps
    ) {
        uint256 count = withdrawHistory[_user].length;
        amounts = new uint256[](count);
        timestamps = new uint256[](count);
    
        for(uint256 i=0; i<count; i++) {
            WithdrawInfo storage wd = withdrawHistory[_user][i];
            amounts[i] = wd.amount;
            timestamps[i] = wd.timestamp;
        }
    }

    function getReferralEarnings(address _user) public view returns (
        uint256 totalReferralRewards,
        uint256 totalTeamDeposits,
        uint256 referralCount
    ) {
        User storage user = users[_user];
        totalReferralRewards = user.totalClaimed;
        totalTeamDeposits = 0;
        for(uint256 i=0; i<5; i++) {
            totalTeamDeposits += user.levelDeposits[i];
        }
        referralCount = user.referralCount;
    }

    function getTotalStaked(address _user) public view returns (uint256) {
        uint256 total;
        for(uint256 i=0; i<userStakes[_user].length; i++) {
            if(userStakes[_user][i].isActive) {
                total += userStakes[_user][i].amount;
            }
        }
        return total;
    }

    function getUserStakeDetails(address _user) public view returns (
        uint256 manualStake,
        uint256 autoStake,
        uint256 totalStake,
        uint256 remainingManualLimit
    ) {
        manualStake = users[_user].totalManualStaked;
        totalStake = users[_user].totalStaked;
        autoStake = totalStake - manualStake;
        remainingManualLimit = maxManualStakePerUser - manualStake;
    }

    function getUserLevel(address _user) public view returns (uint256) {
        return curUserLevel[_user];
    }

    function getValidReferrals(address _user) public view returns (uint256) {
        return validDeposit[_user];
    }

    function getTotalReferralEarnings(address _user) public view returns (uint256) {
        uint256 total;
        for(uint256 i=0; i<5; i++) {
            total += users[_user].levelDeposits[i] * directRewardPercents[i] / 100;
        }
        return total;
    }

    function getMinWithdrawInfo() public view returns (uint256) {
        return (minVNTWithdraw);
    }

    function getContractStats() public view returns (
        uint256 usersCount,
        uint256 totalStaked,
        uint256 activeStake,
        uint256 vntWithdrawn,
        uint256 txCount
    ) {
        return (
            totalUsers,
            totalStakedInContract,
            totalActiveStake,
            totalVNTWithdrawn,
            totalStakingTransactions
        );
    }

    function getTeamUsersPaginated(address _user, uint256 _level, uint256 start, uint256 limit) public view returns (address[] memory) {
        address[] memory team = teamUsers[_user][_level];
        address[] memory result = new address[](limit);
        for (uint256 i = 0; i < limit && start + i < team.length; i++) {
            result[i] = team[start + i];
        }
        return result;
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
        emit ContractPaused(_paused);
    }

    function emergencyStopContract() external onlyOwner {
        emergencyStop = true;
        emit EmergencyStopped(msg.sender, true);
    }

    function resumeContract() external onlyOwner {
        emergencyStop = false;
        emit EmergencyStopped(msg.sender, false);
    }

    function setWalletAddresses(
        address _vnstStakingWallet,
        address _vntRewardWallet,
        address _usdtRewardWallet,
        address _vnstAutoStakeWallet,
        address _feeWallet
    ) external onlyOwner {
        vnstStakingWallet = _vnstStakingWallet;
        vntRewardWallet = _vntRewardWallet;
        usdtRewardWallet = _usdtRewardWallet;
        vnstAutoStakeWallet = _vnstAutoStakeWallet;
        feeWallet = _feeWallet;
    }

    function setStakeLimits(uint256 _min, uint256 _max) external onlyOwner {
        minStakeAmount = _min;
        maxStakeAmount = _max;
    }

    function setBlacklist(address user, bool status) external onlyOwner {
        blacklisted[user] = status;
        emit UserStatusChanged(user, "blacklist", status);
    }

    function setWhitelist(address user, bool status) external onlyOwner {
        whitelisted[user] = status;
        emit UserStatusChanged(user, "whitelist", status);
    }

    function setMinWithdrawLimits(uint256 _minVNT) external onlyOwner {
        minVNTWithdraw = _minVNT;
        emit MinWithdrawAmountsChanged(_minVNT);
    }

    function setMaxManualStakeLimit(uint256 _newLimit) external onlyOwner {
        require(
            _newLimit >= minStakeAmount && 
            _newLimit <= 100000 ether,
            "Invalid limit range"
        );
        maxManualStakePerUser = _newLimit;
        emit MaxManualStakeLimitUpdated(_newLimit);
    }

    function setDirectRewardPercents(uint256[5] memory newPercents) external onlyOwner {
        require(
            newPercents[0] <= 10 && 
            newPercents[1] <= 8 && 
            newPercents[2] <= 6 &&
            newPercents[3] <= 4 &&
            newPercents[4] <= 2,
            "Invalid percentages"
        );
        directRewardPercents = newPercents;
        emit DirectRewardPercentsChanged(newPercents);
    }

    function emergencyWithdraw(address token, uint256 amount) external onlyOwner whenNotEmergencyStopped {
        require(IERC20(token).transfer(owner, amount), "Withdraw failed");
    }

    function emergencyWithdrawAllFunds(address token) external onlyOwner {
        require(emergencyStop, "Not in emergency mode");
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(owner, balance);
    }
}