/**
 *Submitted for verification at BscScan.com on 2025-08-05
*/

//SPDX-License-Identifier: MIT Licensed
pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}
contract Tip_Coin_Presale is Ownable {
    IERC20 public mainToken;
    IERC20 public USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    AggregatorV3Interface public priceFeed;
    uint256 public soldToken;
    uint256 public amountRaised;
    uint256 public amountRaisedUSDT;
    uint256 public amountRaisedOverall;
    uint256 public uniqueBuyers;
    address payable public fundReceiver;
    uint256 public tokensToSell;
    uint256 public tokenPerUsdPrice;
    uint256 public minimumToBuy = 14285714285714285714;
    bool public presaleStatus;
    bool public isPresaleEnded;
    bool public isClaimEnabled;
    address[] public UsersAddresses;
    struct User {
        uint256 bnb_invested;
        uint256 usdt_invested;
        uint256 purchased_tokens;
        uint256 claimed_tokens;
    }
    mapping(address => User) public users;
    mapping(address => bool) public isExist;
    event BuyToken(address indexed _user, uint256 indexed _amount);
    event ClaimToken(address indexed _user, uint256 indexed _amount);
    event UpdatePrice(uint256 _oldPrice, uint256 _newPrice);
    constructor(IERC20 _token, address _fundReceiver) {
        mainToken = _token;
        tokensToSell = 1000000e18;
        tokenPerUsdPrice = 142857142857142858;
        fundReceiver = payable(_fundReceiver);
        priceFeed = AggregatorV3Interface(
            0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        );
    }
    function getLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
    }
    function buyToken() public payable {
        require(!isPresaleEnded, "Presale ended!");
        require(presaleStatus, " Presale is Paused, check back later");
        if (!isExist[msg.sender]) {
            isExist[msg.sender] = true;
            uniqueBuyers++;
            UsersAddresses.push(msg.sender);
        }
        fundReceiver.transfer(msg.value);
        uint256 numberOfTokens;
        numberOfTokens = bnbToToken(msg.value);
        require(
            numberOfTokens >= minimumToBuy,
            "Purchase must exceed the minimum limit."
        );
        require(
            soldToken + numberOfTokens <= tokensToSell,
            "Presale Sold Out"
        );
        soldToken = soldToken + (numberOfTokens);
        amountRaised = amountRaised + msg.value;
        amountRaisedOverall = amountRaisedOverall + bnbToUsdt(msg.value);

        users[msg.sender].bnb_invested += (msg.value);
        users[msg.sender].purchased_tokens += numberOfTokens;
    }
    function buyTokenUSDT(uint256 amount) public {
        require(!isPresaleEnded, "Presale ended!");
        require(presaleStatus, " Presale is Paused, check back later");
        if (!isExist[msg.sender]) {
            isExist[msg.sender] = true;
            uniqueBuyers++;
            UsersAddresses.push(msg.sender);
        }
        USDT.transferFrom(msg.sender, fundReceiver, amount);
        uint256 numberOfTokens;
        numberOfTokens = usdtToToken(amount);
        require(
            numberOfTokens >= minimumToBuy,
            "Purchase must exceed the minimum limit."
        );
        require(
            soldToken + numberOfTokens <= tokensToSell,
            "Presale Sold Out"
        );
        soldToken = soldToken + numberOfTokens;
        amountRaisedUSDT = amountRaisedUSDT + amount;
        amountRaisedOverall = amountRaisedOverall + amount;

        users[msg.sender].usdt_invested += amount;
        users[msg.sender].purchased_tokens += numberOfTokens;
    }
    
    function claimTokens() external {
        require(isPresaleEnded, "Presale has not ended yet");
        require(isClaimEnabled, "Claim has not enabled yet");
        User storage user = users[msg.sender];
        require(user.purchased_tokens > 0, "You have no tokens to claim");
        uint256 claimableTokens = user.purchased_tokens - user.claimed_tokens;
        require(claimableTokens > 0, "You have no tokens to claim");
        user.claimed_tokens += claimableTokens;
        mainToken.transfer(msg.sender, claimableTokens);
        emit ClaimToken(msg.sender, claimableTokens);
    }
    function setPresaleStatus(bool _status) external onlyOwner {
        presaleStatus = _status;
    }
    function endPresale() external onlyOwner {
        isPresaleEnded = true;
    }
    function startClaim() external onlyOwner {
        isClaimEnabled = true;
    }
    function bnbToToken(uint256 _amount) public view returns (uint256) {
        uint256 ethToUsd = (_amount * (getLatestPrice())) / (1 ether);
        uint256 numberOfTokens = (ethToUsd * tokenPerUsdPrice) / (1e8);
        return numberOfTokens;
    }
    // BNB to USD
    function bnbToUsdt(uint256 _amount) public view returns (uint256) {
        uint256 bnbToUsd = (_amount * (getLatestPrice())) / (1e8);
        return bnbToUsd;
    }
    function usdtToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = (_amount * tokenPerUsdPrice) / (1e18);
        return numberOfTokens;
    }
    function initiateTransfer(uint256 _value) external onlyOwner {
        fundReceiver.transfer(_value);
    }
    function totalUsersCount() external view returns (uint256) {
        return UsersAddresses.length;
    }
    function transferTokens(IERC20 token, uint256 _value) external onlyOwner {
        token.transfer(msg.sender, _value);
    }
}