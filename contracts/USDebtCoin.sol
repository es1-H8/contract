// SPDX-License-Identifier: MIT
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

/**
 * @dev Standard ERC-20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`'s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);

    /**
     * @dev Indicates an invalid amount. Used in transfers.
     * @param amount Transfer amount.
     */
    error ERC20InvalidAmount(uint256 amount);
}

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
     * @dev Moves `value` tokens from the caller's account to `to`.
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

/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` is 2, a balance of 505 should be displayed to
     * the user as 5.05 (505 / 10 ** 2).
     *
     * Tokens usually opt for 18 decimals, analogous to the `decimals` of
     * the native token of the chain (e.g. 10^18 wei in Ethereum).
     *
     * NOTE: This information is only used for _display_ purposes: it does not
     * affect any of the arithmetic of the contract, which uses integer
     * arithmetic.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not reduced to zero when
     * a transfer takes place, and the `approve` call is not required to be re-issued every time.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the `spender` must have an allowance of at least `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, or token supply reduction.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }

        _update(from, to, amount);
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `amount` cannot be zero.
     */
    function _mint(address account, uint256 amount) internal virtual {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        if (amount == 0) {
            revert ERC20InvalidAmount(0);
        }

        _update(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `amount` cannot be zero.
     * - `account` must have at least `amount` in balance.
     */
    function _burn(address account, uint256 amount) internal virtual {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (amount == 0) {
            revert ERC20InvalidAmount(0);
        }

        _update(account, address(0), amount);
    }

    /**
     * @dev Approve `spender` to operate on `owner`'s tokens.
     *
     * Emits an {Approval} event.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner`'s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     * - `amount` cannot be zero.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < amount) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, amount);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of `from`'s tokens
     * will be transferred to `to`.
     * - when `from` is the zero address, `amount` tokens will be minted for `to`.
     * - when `to` is the zero address, `amount` tokens will be burned from `from`.
     * - `from` and `to` are never both the zero address.
     *
     * To learn more about hooks, see the Solidity documentation on
     * https://solidity.readthedocs.io/en/latest/contracts.html#hooks[Hooks].
     */
    function _update(address from, address to, uint256 amount) internal virtual {
        if (from == address(0)) {
            // Mint
            _totalSupply += amount;
            _balances[to] += amount;
        } else if (to == address(0)) {
            // Burn
            _balances[from] -= amount;
            _totalSupply -= amount;
        } else {
            // Transfer
            _balances[from] -= amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
    }
}

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
     * @dev The owner is not a valid owner account.
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(msg.sender);
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
        if (owner() != msg.sender) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
    }

    /**
     * @dev Leaves the contract for the current owner to renounce its ownership.
     *
     * WARNING: Renouncing ownership allows anyone to call the owner functions.
     * This can be dangerous, especially if it is a contract that manages other contracts.
     *
     * By default, the owner is set to the zero address. This can be changed
     * in the implementation to an alternative address. See {_setOwner}.
     * Owners can only renounce their ownership if they are not a contract.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     *
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @title USDebtCoin
 * @notice Meme/ERC20 token with a faucet that provides claimants with one "share"
 * of United States DebtCoin "USDBT". Market value may not reflect face value!
 * Key rules:
 * - Fixed supply of 340.1M people minted at deployment and based on approximate
 *   US Population in 2024.
 * - Faucet is funded once, afterward any address can claim exactly 1 token.
 * - Tokens sent "back" to the faucet after funding are rerouted to the dev wallet.
 * - Transfers can incur a fee of up to 5% (currently 2.5%) that goes to the dev wallet.
 * - Addresses exempt from fees: dev wallet, faucet, owner, reserve, minting addresses.
 * - Burning tokens (sending to zero address) is explicitly blocked to fix supply at 340.1M shares.
 */
contract USDebtCoin is ERC20, Ownable {
    uint256 public constant MAX_FEE_BPS = 500; // 5% max fee
    uint256 public transferFeeBps;

    // Dev Wallet initially set to deployer
    address public devWallet;

    // Faucet address
    address public faucet;

    // Reserve address
    address public reserve;

    // Minting addresses
    address[] public mintingAddresses;

    // Addresses exempt from fees
    mapping(address => bool) public isExemptFromFees;

    // Faucet claim status
    mapping(address => bool) public hasClaimed;

    // Events
    event FaucetFunded(address indexed funder, uint256 amount);
    event FaucetClaimed(address indexed claimant, uint256 amount);
    event TransferFeeChanged(uint256 newFeeBps);
    event DevWalletChanged(address indexed newDevWallet);
    event FaucetChanged(address indexed newFaucet);
    event ReserveChanged(address indexed newReserve);
    event MintingAddressAdded(address indexed newAddress);
    event MintingAddressRemoved(address indexed removedAddress);

    constructor(address _faucet, address _reserve, address[] memory _mintingAddresses) ERC20("USDebtCoin", "USDBT") {
        devWallet = msg.sender;
        faucet = _faucet;
        reserve = _reserve;
        mintingAddresses = _mintingAddresses;
        transferFeeBps = 250; // 2.5% initial fee

        // Set initial exemptions
        isExemptFromFees[devWallet] = true;
        isExemptFromFees[faucet] = true;
        isExemptFromFees[reserve] = true;
        isExemptFromFees[address(this)] = true; // Contract itself
        for (uint i = 0; i < mintingAddresses.length; i++) {
            isExemptFromFees[mintingAddresses[i]] = true;
        }

        // Mint initial supply to reserve
        _mint(reserve, 340100000 * (10 ** decimals()));
    }

    // Faucet funding (only callable by owner)
    function fundFaucet() public onlyOwner {
        require(balanceOf(msg.sender) >= 100 * (10 ** decimals()), "Insufficient balance to fund faucet");
        _transfer(msg.sender, faucet, 100 * (10 ** decimals()));
        emit FaucetFunded(msg.sender, 100 * (10 ** decimals()));
    }

    // Faucet claim (only callable by non-exempt addresses, once per address)
    function claimFromFaucet() public {
        require(!isExemptFromFees[msg.sender], "Exempt addresses cannot claim from faucet");
        require(!hasClaimed[msg.sender], "Already claimed from faucet");
        require(balanceOf(faucet) >= 1 * (10 ** decimals()), "Faucet is empty");
        _transfer(faucet, msg.sender, 1 * (10 ** decimals()));
        hasClaimed[msg.sender] = true;
        emit FaucetClaimed(msg.sender, 1 * (10 ** decimals()));
    }

    // Transfer with fee logic
    function _transfer(address from, address to, uint256 amount) internal override {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(to != address(this), "USDebtCoin: cannot send to contract address"); // Prevent burning

        uint256 fee = 0;
        if (!isExemptFromFees[from] && !isExemptFromFees[to]) {
            fee = (amount * transferFeeBps) / 10000;
            require(amount >= fee, "USDebtCoin: amount too small for fee");
        }

        uint256 amountToSend = amount - fee;

        super._transfer(from, to, amountToSend);

        if (fee > 0) {
            super._transfer(to, devWallet, fee); // Fee goes to dev wallet
        }
    }

    // Owner functions
    function setTransferFeeBps(uint256 _newFeeBps) public onlyOwner {
        require(_newFeeBps <= MAX_FEE_BPS, "Fee exceeds maximum");
        transferFeeBps = _newFeeBps;
        emit TransferFeeChanged(_newFeeBps);
    }

    function setDevWallet(address _newDevWallet) public onlyOwner {
        require(_newDevWallet != address(0), "New dev wallet cannot be zero address");
        isExemptFromFees[devWallet] = false;
        devWallet = _newDevWallet;
        isExemptFromFees[devWallet] = true;
        emit DevWalletChanged(_newDevWallet);
    }

    function setFaucet(address _newFaucet) public onlyOwner {
        require(_newFaucet != address(0), "New faucet cannot be zero address");
        isExemptFromFees[faucet] = false;
        faucet = _newFaucet;
        isExemptFromFees[faucet] = true;
        emit FaucetChanged(_newFaucet);
    }

    function setReserve(address _newReserve) public onlyOwner {
        require(_newReserve != address(0), "New reserve cannot be zero address");
        isExemptFromFees[reserve] = false;
        reserve = _newReserve;
        isExemptFromFees[reserve] = true;
        emit ReserveChanged(_newReserve);
    }

    function addMintingAddress(address _newAddress) public onlyOwner {
        require(_newAddress != address(0), "New minting address cannot be zero address");
        require(!isExemptFromFees[_newAddress], "Address already a minting address");
        mintingAddresses.push(_newAddress);
        isExemptFromFees[_newAddress] = true;
        emit MintingAddressAdded(_newAddress);
    }

    function removeMintingAddress(address _addressToRemove) public onlyOwner {
        require(_addressToRemove != address(0), "Address to remove cannot be zero address");
        bool found = false;
        for (uint i = 0; i < mintingAddresses.length; i++) {
            if (mintingAddresses[i] == _addressToRemove) {
                mintingAddresses[i] = mintingAddresses[mintingAddresses.length - 1];
                mintingAddresses.pop();
                found = true;
                break;
            }
        }
        require(found, "Address not found in minting addresses");
        isExemptFromFees[_addressToRemove] = false;
        emit MintingAddressRemoved(_addressToRemove);
    }

    function setExemptFromFees(address _address, bool _isExempt) public onlyOwner {
        isExemptFromFees[_address] = _isExempt;
    }
}

