// SPDX-License-Identifier: UNLICENSED
/**
 *Submitted for verification at BscScan.com on 2025-08-05
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: contracts/patricia_presale.sol


pragma solidity ^0.8.20;




contract MemePresale is Ownable, ReentrancyGuard {
    IERC20 public token;        // PatriciaToken (MEME)
    IERC20 public usdt;         // USDT (18 decimals on BSC)
    IERC20 public usdc;         // USDC (18 decimals on BSC)

    address payable public treasury;

    uint256 public rateBNB = 70000 * 1e18;     // 1 BNB = 70,000 MEME
    uint256 public rateUSDT = 100 * 1e18;      // 1 USDT = 100 MEME
    uint256 public rateUSDC = 100 * 1e18;     // 1 USDC = 100 MEME

    uint256 public minBNB = 0.01 ether;
    uint256 public maxBNB = 10 ether;
    uint256 public minStable = 10 * 1e18;   // 10 USDT or USDC
    uint256 public maxStable = 5000 * 1e18;  // 5000 USDT or USDC

    uint256 public totalTokensForPresale;
    uint256 public tokensSold;
    bool public presaleActive = true;

    mapping(address => uint256) public bnbContributions;
    mapping(address => uint256) public stableContributions;

    event TokensPurchased(address indexed buyer, uint256 amountPaid, uint256 tokensReceived, string currency);
    event PresaleEnded();

    constructor(
        IERC20 _token,
        IERC20 _usdt,
        IERC20 _usdc,
        address payable _treasury,
        uint256 _totalSupply
    ) Ownable(msg.sender) {
        require(address(_token) != address(0), "Token address is zero");
        require(address(_usdt) != address(0), "USDT address is zero");
        require(address(_usdc) != address(0), "USDC address is zero");
        require(_treasury != address(0), "Treasury address is zero");

        token = _token;
        usdt = _usdt;
        usdc = _usdc;
        treasury = _treasury;
        totalTokensForPresale = _totalSupply / 5; // 20% of supply for presale
    }

    function buyWithBNB() external payable nonReentrant {
        require(presaleActive, "Presale has ended");
        require(msg.value >= minBNB && msg.value <= maxBNB, "Invalid BNB amount");
        require(bnbContributions[msg.sender] + msg.value <= maxBNB, "Exceeds max BNB per wallet");

        uint256 tokenAmount = (msg.value * rateBNB);
        require(tokensSold + tokenAmount <= totalTokensForPresale, "Presale sold out");

        // Effects
        bnbContributions[msg.sender] += msg.value;
        tokensSold += tokenAmount;

        if (tokensSold >= totalTokensForPresale) {
            presaleActive = false;
            emit PresaleEnded();
        }

        // Interactions
        require(IERC20(token).transfer(msg.sender, tokenAmount), "Token transfer failed");
        (bool sent, ) = treasury.call{value: msg.value}("");
        require(sent, "BNB transfer failed");

        emit TokensPurchased(msg.sender, msg.value, tokenAmount, "BNB");
    }

    function buyWithUSDT(uint256 usdtAmount) external nonReentrant {
        require(presaleActive, "Presale has ended");
        require(usdtAmount >= minStable && usdtAmount <= maxStable, "Invalid USDT amount");
        require(stableContributions[msg.sender] + usdtAmount <= maxStable, "Exceeds max stable per wallet");

        uint256 tokenAmount = (usdtAmount * rateUSDT);
        require(tokensSold + tokenAmount <= totalTokensForPresale, "Presale sold out");

        // Effects
        stableContributions[msg.sender] += usdtAmount;
        tokensSold += tokenAmount;

        if (tokensSold >= totalTokensForPresale) {
            presaleActive = false;
            emit PresaleEnded();
        }

        // Interactions
        require(usdt.transferFrom(msg.sender, treasury, usdtAmount), "USDT transfer failed");
        require(token.transfer(msg.sender, tokenAmount), "Token transfer failed");

        emit TokensPurchased(msg.sender, usdtAmount, tokenAmount, "USDT");
    }

    function buyWithUSDC(uint256 usdcAmount) external nonReentrant {
        require(presaleActive, "Presale has ended");
        require(usdcAmount >= minStable && usdcAmount <= maxStable, "Invalid USDC amount");
        require(stableContributions[msg.sender] + usdcAmount <= maxStable, "Exceeds max stable per wallet");

        uint256 tokenAmount = (usdcAmount * rateUSDC);
        require(tokensSold + tokenAmount <= totalTokensForPresale, "Presale sold out");

        // Effects
        stableContributions[msg.sender] += usdcAmount;
        tokensSold += tokenAmount;

        if (tokensSold >= totalTokensForPresale) {
            presaleActive = false;
            emit PresaleEnded();
        }

        // Interactions
        require(usdc.transferFrom(msg.sender, treasury, usdcAmount), "USDC transfer failed");
        require(token.transfer(msg.sender, tokenAmount), "Token transfer failed");

        emit TokensPurchased(msg.sender, usdcAmount, tokenAmount, "USDC");
    }

    function withdrawUnsoldTokens() external onlyOwner {
        require(!presaleActive, "Presale is still active");
        require(tokensSold < totalTokensForPresale, "No unsold tokens to withdraw");

        uint256 remainingTokens = totalTokensForPresale - tokensSold;
        require(token.transfer(owner(), remainingTokens), "Token transfer failed");
    }

    receive() external payable {
        revert("Use buyWithBNB function");
    }

    fallback() external payable {
        revert("Invalid call");
    }
}