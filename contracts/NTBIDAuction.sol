// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */
abstract contract Ownable is Context {
    address private _owner;

    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

/**
 * @title NTBIDAuction
 * @dev A contract for conducting auctions using an ERC20 token.
 */
contract NTBIDAuction is Ownable {
    uint64 public constant EXTENSION_THRESHOLD = 2 minutes;
    uint64 public constant EXTENSION_TIME = 2 minutes;

    struct Auction {
        address auctionWallet;
        address highestBidder;
        uint64 startTime;
        uint64 endTime;
        bool auctionActive;
        uint256 minimumIncreaseAmount;
        uint256 minimumStartingBid;
        uint256 highestBid;
    }

    Auction public auction;
    mapping(address bidder => uint256 bidAmount) public auctionBids;
    address[] public bidderAddresses;
    uint32 public nextAuctionId = 1;
    IERC20 public bytesToken;

    event AuctionStarted(uint32 indexed auctionId, uint64 endTime);
    event AuctionEnded(uint32 indexed auctionId, address winner, uint256 winningBid);
    event BidPlaced(uint32 indexed auctionId, address indexed bidder, uint256 amount);
    event MinimumIncreaseAmountUpdated(uint256 newMinimumIncreaseAmount);
    event AuctionWalletUpdated(address newAuctionWallet);

    error InvalidTokenAddress();
    error InvalidAuctionWallet(address auctionWallet);
    error InvalidMinimumStartingBid(uint256 minimumStartingBid);
    error InvalidMinimumIncreaseAmount(uint256 minimumIncreaseAmount);
    error AuctionNotActive(uint32 auctionId);
    error AuctionHasEnded(uint32 auctionId);
    error BidAmountTooLow(uint32 auctionId, uint256 bidAmount);
    error TokenTransferFailed();
    error AuctionAlreadyActive(uint32 auctionId);

    constructor(address _bytesToken) Ownable(msg.sender) {
        if (_bytesToken == address(0)) revert InvalidTokenAddress();
        bytesToken = IERC20(_bytesToken);
    }

    modifier onlyWhenAuctionActive(uint32 auctionId) {
        if (!auction.auctionActive) revert AuctionNotActive(auctionId);
        if (block.timestamp >= auction.endTime) revert AuctionHasEnded(auctionId);
        _;
    }

    function startAuction(address auctionWallet, uint256 minimumStartingBid, uint256 minimumIncreaseAmount, uint64 duration) external onlyOwner {
        uint32 auctionId = nextAuctionId++;

        if (auction.auctionActive) revert AuctionAlreadyActive(auctionId);
        if (minimumStartingBid == 0) revert InvalidMinimumStartingBid(minimumStartingBid);
        if (minimumIncreaseAmount == 0) revert InvalidMinimumIncreaseAmount(minimumIncreaseAmount);

        auction = Auction({
            auctionWallet: auctionWallet,
            auctionActive: true,
            startTime: uint64(block.timestamp),
            endTime: uint64(block.timestamp + duration),
            minimumIncreaseAmount: minimumIncreaseAmount,
            minimumStartingBid: minimumStartingBid,
            highestBid: 0,
            highestBidder: address(0)
        });

        emit AuctionStarted(auctionId, auction.endTime);
    }

    function endAuction(uint32 auctionId) external onlyOwner {
        if (!auction.auctionActive) revert AuctionNotActive(auctionId);

        auction.auctionActive = false;

        for (uint256 i = 0; i < bidderAddresses.length; i++) {
            address bidder = bidderAddresses[i];
            uint256 bidAmount = auctionBids[bidder];

            if (bidder == auction.highestBidder) {
                if (!bytesToken.transfer(auction.auctionWallet, bidAmount)) revert TokenTransferFailed();
            } else {
                if (!bytesToken.transfer(bidder, bidAmount)) revert TokenTransferFailed();
            }

            delete auctionBids[bidder];
        }
        delete bidderAddresses;

        emit AuctionEnded(auctionId, auction.highestBidder, auction.highestBid);
    }

    function bid(uint32 auctionId, uint256 amount) external onlyWhenAuctionActive(auctionId) {
        if (!auction.auctionActive) revert AuctionNotActive(auctionId);

        uint256 existingBid = auctionBids[msg.sender];
        uint256 newBid = existingBid + amount;

        if (newBid < auction.minimumStartingBid) revert BidAmountTooLow(auctionId, newBid);

        if (block.timestamp > auction.endTime - EXTENSION_THRESHOLD) {
            auction.endTime = uint64(auction.endTime + EXTENSION_TIME);
        }

        uint256 minimumCurrentBid = auction.highestBid + auction.minimumIncreaseAmount;
        if (newBid < minimumCurrentBid) revert BidAmountTooLow(auctionId, newBid);

        if (!bytesToken.transferFrom(msg.sender, address(this), amount)) revert TokenTransferFailed();

        if (auctionBids[msg.sender] == 0) {
            bidderAddresses.push(msg.sender);
        }
        auctionBids[msg.sender] = newBid;

        if (newBid > auction.highestBid) {
            auction.highestBid = newBid;
            auction.highestBidder = msg.sender;
        }

        if (newBid > 3000 ether) {
            auction.minimumIncreaseAmount = 50 ether;
        } else if (newBid > 2000 ether) {
            auction.minimumIncreaseAmount = 25 ether;
        } else if (newBid > 1000 ether) {
            auction.minimumIncreaseAmount = 10 ether;
        }

        emit BidPlaced(auctionId, msg.sender, newBid);
    }

    function updateMinimumIncreaseAmount(uint32 auctionId, uint256 minimumIncreaseAmount) external onlyOwner {
        if (!auction.auctionActive) revert AuctionNotActive(auctionId);
        if (minimumIncreaseAmount == 0) revert InvalidMinimumIncreaseAmount(minimumIncreaseAmount);

        auction.minimumIncreaseAmount = minimumIncreaseAmount;

        emit MinimumIncreaseAmountUpdated(minimumIncreaseAmount);
    }

    function updateAuctionWallet(address newAuctionWallet) external onlyOwner {
        if (newAuctionWallet == address(0)) revert InvalidAuctionWallet(newAuctionWallet);

        auction.auctionWallet = newAuctionWallet;

        emit AuctionWalletUpdated(newAuctionWallet);
    }

    function getEndTimeAndIncrement() public view returns (uint64 endTime, uint256 incrementAmount) {
        endTime = auction.endTime;
        incrementAmount = auction.minimumIncreaseAmount;
    }
}