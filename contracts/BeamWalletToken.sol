/**
 *Submitted for verification at Etherscan.io on 2025-08-05
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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;


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

// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol


// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

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
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
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
}

/**
 * @dev Standard ERC-721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in ERC-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC-1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v5.3.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;





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
 * conventional and does not conflict with the expectations of ERC-20
 * applications.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * Both values are immutable: they can only be set once during construction.
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
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
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
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
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
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Skips emitting an {Approval} event indicating an allowance update. This is not
     * required by the ERC. See {xref-ERC20-_approve-address-address-uint256-bool-}[_approve].
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner`'s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     *
     * ```solidity
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner`'s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance < type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;


// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC165.sol


// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC165.sol)

pragma solidity ^0.8.20;


// File: @openzeppelin/contracts/interfaces/IERC1363.sol


// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/IERC1363.sol)

pragma solidity ^0.8.20;



/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v5.3.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Variant of {safeTransfer} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransfer(IERC20 token, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Variant of {safeTransferFrom} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
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

// File: @openzeppelin/contracts/utils/Errors.sol


// OpenZeppelin Contracts (last updated v5.1.0) (utils/Errors.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of common custom errors used in multiple contracts
 *
 * IMPORTANT: Backwards compatibility is not guaranteed in future versions of the library.
 * It is recommended to avoid relying on the error API for critical functionality.
 *
 * _Available since v5.1._
 */
library Errors {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error InsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedCall();

    /**
     * @dev The deployment failed.
     */
    error FailedDeployment();

    /**
     * @dev A necessary precompile is missing.
     */
    error MissingPrecompile(address);
}

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v5.2.0) (utils/Address.sol)

pragma solidity ^0.8.20;


/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert Errors.InsufficientBalance(address(this).balance, amount);
        }

        (bool success, bytes memory returndata) = recipient.call{value: amount}("");
        if (!success) {
            _revert(returndata);
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {Errors.FailedCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert Errors.InsufficientBalance(address(this).balance, value);
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {Errors.FailedCall}) in case
     * of an unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {Errors.FailedCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {Errors.FailedCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            assembly ("memory-safe") {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert Errors.FailedCall();
        }
    }
}

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

// File: contracts/bwtv16.sol


pragma solidity ^0.8.20;







/// @title BeamWalletToken
/// @notice Este contrato implementa a venda de Beam Tokens (BWT) conforme os requisitos,
///         utilizando BNT como token de reserva na pool de liquidez.
contract BeamWalletToken is ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;
    using Address for address payable;

    // ----------------------------
    //          Variáveis
    // ----------------------------
    
    AggregatorV3Interface private immutable _priceFeed;
    AggregatorV3Interface public ethUsdFeed;
    AggregatorV3Interface public bntEthFeed;
    
    // Endereço da carteira GBC SA (substitua pelo endereço real)
    address public constant GBC_SA_POOL = 0x8F88BCCE5796755450757881BFee569c00d80EB0;
    address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;


    // As fases de venda
    enum SalePhase { PrivateSale, PrePublicSale, PublicSale }
    SalePhase public currentSalePhase;

    struct SalePhaseInfo {
        uint256 minTokens;
        uint256 maxTokens;
        uint256 priceInCents; // Em cents USD (ex.: 2 = 0.02 USD)
        uint256 startTime;
        uint256 endTime;
    }

    struct SaleRecord {
        uint256 phase;
        uint256 price;
        uint256 tokensSold;
        uint256 revenue;
        uint256 blockTime;
    }

    SaleRecord[] public salesHistory;
    mapping(SalePhase => SalePhaseInfo) public salePhaseDetails;

    // Condições gerais
    uint256 public constant MAX_TOTAL_SUPPLY = 10_000_000_000 * 10**18;
    uint256 public BONUS_TOKENS = 3_500_000_000 * 10**18;
    uint256 public constant LOCK_PERIOD = 2 * 365 days;

    uint256 public totalTokensSold = 0;
    uint256 public basePublicSalePrice = 100; // Base price em cents USD para Public Sale
    uint256 public PRIVATE_SALE_CAP = 2_000_000_000 * 10**decimals();
    uint256 public totalTokensSoldPrivateSale;
    uint256 public totalTokensSoldPrePublicSale;

    IERC20 public BNT;
    uint256 public BNTBalance;
    // Connector weight: atualmente definido como 80 (se necessário, altere para 50)
    uint256 public connectorWeight = 8000;

    string public constant TOKEN_NAME = "BeamToken";
    string public constant TOKEN_SYMBOL = "BWT";

    // Tracking de holders para bloqueio
    address[] private _holders;
    mapping(address => bool) private _isHolder;
    mapping(address => uint256) public preSaleLockedBalance;

    // Variáveis de bloqueio
    bool public isLocked;
    uint256 public lockTimestamp;
    
    // Endereço do contrato Bancor Swap para conversões
    address public bancorSwapContract;

    // Tracking interno de saldos
    mapping(address => uint256) public lockedBalance;
    mapping(address => uint256) public unlockedBalance;
    mapping(address => uint256) public contributionAmount;
    mapping(address => uint256) public newPublicBalance;
    mapping(address => uint256) public totalBeamPurchasedByUser;
    uint256 public totalBonusTokensDistributed;

    // Limitação de compra: cada usuário pode comprar 88 BWT a cada 24 horas (editável)
    uint256 public purchaseLimit = 88 * 10**decimals();
    uint256 public dailyPurchaseLimit = 88 * 10**decimals();
    uint256 public purchasePeriod = 24 hours; // Se 0, desativa a limitação
    mapping(address => uint256) public lastPurchaseTimestamp;
    mapping(address => uint256) public tokensPurchasedInPeriod;
    
    // Proteção contra gas price excessivo (em wei)
    uint256 public maxGasPrice = 100 gwei;
    // Limite para retirada de Ether (se 0, sem limite)
    uint256 public maxEtherWithdrawal;
    // percentagem da taxa de transação
    uint256 public feePercentage = 5; // Default 5% fee
    address public feeCollector;


    // ----------------------------
    //          Eventos
    // ----------------------------
    
    event TokensTransferredToGBC(address indexed gbcPool, uint256 amount);
    event LiquidityAdded(uint256 BNTAmount, uint256 BeamTokenAmount);
    event BeamBought(address indexed buyer, uint256 beamAmount, uint256 bntAmount);
    event BeamSold(address indexed seller, uint256 beamAmount, uint256 bntAmount);
    event PrivateSaleEnded();
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 ethSpent, uint256 usdValue, uint256 bonusTokens);
    event TokensTransferred(address indexed from, address indexed to, uint256 amount);
    event PhaseAdvanced(SalePhase newPhase);
    event EtherWithdrawn(address indexed owner, uint256 amount);
    event SalePhaseUpdated(SalePhase phase, uint256 startTime, uint256 endTime);
    event TokensLocked(address indexed account, uint256 amount);
    event TokensUnlocked(address indexed account, uint256 amount);
    event PriceAdjusted(uint256 newPrice);
    event MaximumInvestmentUpdated(SalePhase phase, uint256 newMaxTokens);
    event SaleRecorded(uint256 phase, uint256 price, uint256 tokensSold, uint256 revenue, uint256 blockTime);
    event PastPrivateSaleRecorded(address indexed buyer, uint256 tokensSold, uint256 price, uint256 revenue, uint256 timestamp);
    event PurchaseLimitUpdated(uint256 newLimit);
    event DailyPurchaseLimitUpdated(uint256 newLimit);
    event PurchasePeriodUpdated(uint256 newPeriod);
    event MaxGasPriceUpdated(uint256 newGasPrice);
    event BancorSwapContractUpdated(address newContract);
    event FeeCollectorUpdated(address newCollector);
    event BuyFeeUpdated(uint256 newFeePercent);
    event ConnectorWeightUpdated(uint256 newConnectorWeight);

    // ----------------------------
    //       Erros personalizados
    // ----------------------------
    
    error ExceedsMaxSupply();
    error InvalidBuyer();
    error InvalidTokenAmount();
    error MismatchedInputLengths();
    error InvalidRecipient();
    error ExceedsTokenBalance();
    error InvalidPhase();
    error TokenAmountOutOfRange(uint256 min, uint256 max);
    error InsufficientETH();
    error FailedETHTransfer();
    error PrivateSaleFinished();
    error PhaseEnded();
    error PhaseNotStarted();
    error TokensAreLocked();
    error GasPriceTooHigh();
    error WithdrawalExceedsLimit();

    // ----------------------------
    //          Modifiers
    // ----------------------------
    
    modifier onlyInPhase(SalePhase phase) {
        if (currentSalePhase != phase) revert InvalidPhase();
        if (block.timestamp < salePhaseDetails[phase].startTime) revert PhaseNotStarted();
        if (block.timestamp > salePhaseDetails[phase].endTime) revert PhaseEnded();
        _;
    }

    modifier gasPriceValid() {
        if (tx.gasprice > maxGasPrice) revert GasPriceTooHigh();
        _;
    }


    // ----------------------------
    //       Funções internas
    // ----------------------------

    /// @dev Bloqueia os tokens adquiridos nas fases Private e PrePublicSale
    function lockPreSaleTokens() internal {
        lockTimestamp = block.timestamp;
        for (uint256 i = 0; i < _holders.length; i++) {
            address holder = _holders[i];
            uint256 amountToLock = preSaleLockedBalance[holder];
            if (amountToLock > 0 && unlockedBalance[holder] >= amountToLock) {
                unlockedBalance[holder] -= amountToLock;
                lockedBalance[holder] += amountToLock;
                preSaleLockedBalance[holder] = 0;
                emit TokensLocked(holder, amountToLock);
            }
        }
        isLocked = true;
    }

    // ----------------------------
    //        Construtor
    // ----------------------------
    
    constructor(
        address priceFeedAddress,
        address _BNTAddress,
        address _bancorSwapContract,
        address ethUsdFeedAddress,
        address bntEthFeedAddress
    ) ERC20(TOKEN_NAME, TOKEN_SYMBOL) Ownable(msg.sender) {
        require(_bancorSwapContract != address(0), "Invalid Swap contract address");
        require(_bancorSwapContract.code.length > 0, "Swap address must be a contract");

        _priceFeed = AggregatorV3Interface(priceFeedAddress);
        ethUsdFeed = AggregatorV3Interface(ethUsdFeedAddress);
        bntEthFeed = AggregatorV3Interface(bntEthFeedAddress);  
        BNT = IERC20(_BNTAddress);
        bancorSwapContract = _bancorSwapContract;
        feeCollector = owner();


        // Exemplo de datas (Unix timestamps)
        uint256 privateSaleStartDate = 1716220800; // 21/05/2024
        uint256 privateSaleEndDate   = 1721510400; // 21/07/2024
        uint256 prePublicSaleStartDate = 1721596800; // 22/07/2024

        // Definições para cada fase
        salePhaseDetails[SalePhase.PrivateSale] = SalePhaseInfo(
            50_000_000 * 10**decimals(),
            2_000_000_000 * 10**decimals(),
            2, // 0,02 USD (em cents)
            privateSaleStartDate,
            privateSaleEndDate
        );
        salePhaseDetails[SalePhase.PrePublicSale] = SalePhaseInfo(
            12_500 * 10**decimals(),
            500_000_000 * 10**decimals(),
            8, // 0,08 USD (em cents)
            prePublicSaleStartDate,
            0 // Data final definida pelo admin
        );
        salePhaseDetails[SalePhase.PublicSale] = SalePhaseInfo(
            30 * 10**decimals(),
            1_000_000_000 * 10**decimals(),
            0,
            0,
            0
        );
        
        // Inicia na fase PrivateSale
        currentSalePhase = SalePhase.PrivateSale;

        // Mint inicial: envia 3 bilhões de tokens para GBC SA
        _mint(GBC_SA_POOL, 3_000_000_000 * 10**decimals());
    }

    // ----------------------------
    //    Structs de Venda Passada
    // ----------------------------

    struct PastPrivateSale {
        address buyer;
        uint256 tokensSold;
        uint256 price;
        uint256 revenue;
        uint256 timestamp;
    }

    PastPrivateSale[] public pastPrivateSales;
    mapping(address => uint256) public tokensDistributedToBuyer;

    // ----------------------------
    //        Funções Owner
    // ----------------------------

    /// @notice Mint manual (apenas Owner)
    function mintTokens(uint256 amount) public onlyOwner {
        if (totalSupply() + amount > MAX_TOTAL_SUPPLY) revert ExceedsMaxSupply();
        _mint(address(this), amount);
    }

    /// @notice Distribui vendas privadas passadas
function distributePastPrivateSales(
    address[] memory buyers,
    uint256[] memory tokenAmounts,
    uint256[] memory prices
) public onlyOwner {
    if (buyers.length != tokenAmounts.length || buyers.length != prices.length) revert MismatchedInputLengths();
    uint256 totalTokensDistributedLocal = 0;

    for (uint256 i = 0; i < buyers.length; i++) {
        if (buyers[i] == address(0)) revert InvalidBuyer();
        if (tokenAmounts[i] == 0) revert InvalidTokenAmount();

        uint256 revenue = tokenAmounts[i] * prices[i];
        uint256 remainingCap = PRIVATE_SALE_CAP - totalTokensSoldPrivateSale;
        if (tokenAmounts[i] > remainingCap) revert("Exceeds private sale cap");
        if (totalSupply() + tokenAmounts[i] > MAX_TOTAL_SUPPLY) revert("Exceeds max supply");

        // ✅ Agora mintamos diretamente para o comprador
        _mint(buyers[i], tokenAmounts[i]);

        pastPrivateSales.push(PastPrivateSale({
            buyer: buyers[i],
            tokensSold: tokenAmounts[i],
            price: prices[i],
            revenue: revenue,
            timestamp: block.timestamp
        }));

        tokensDistributedToBuyer[buyers[i]] += tokenAmounts[i];
        emit PastPrivateSaleRecorded(buyers[i], tokenAmounts[i], prices[i], revenue, block.timestamp);

        totalTokensDistributedLocal += tokenAmounts[i];
    }

    totalTokensSoldPrivateSale += totalTokensDistributedLocal;
    totalTokensSold += totalTokensDistributedLocal;
}


    function getPastPrivateSale(uint256 index) public view returns (PastPrivateSale memory sale) {
        require(index < pastPrivateSales.length, "Invalid index");
        return pastPrivateSales[index];
    }

    function getTotalTokensSoldPrivateSale() public view returns (uint256) {
        return totalTokensSoldPrivateSale;
    }

    function getTokensDistributedToBuyer(address buyer) public view returns (uint256) {
        return tokensDistributedToBuyer[buyer];
    }

    /// @notice Altera a fase atual de venda
    function setSalePhase(SalePhase phase) public onlyOwner {
        currentSalePhase = phase;
    }

    /// @notice Registra uma venda privada manualmente
    function recordPrivateSale(uint256 phase, uint256 price, uint256 tokensSold, uint256 revenue) public onlyOwner {
        salesHistory.push(SaleRecord({
            phase: phase,
            price: price,
            tokensSold: tokensSold,
            revenue: revenue,
            blockTime: block.timestamp
        }));
        emit SaleRecorded(phase, price, tokensSold, revenue, block.timestamp);
    }

    function getSaleHistory(uint256 index) public view returns (SaleRecord memory) {
        require(index < salesHistory.length, "Index out of bounds");
        return salesHistory[index];
    }

    function totalSalesRecords() public view returns (uint256) {
        return salesHistory.length;
    }

    // ----------------------------
    //  Adicionar Liquidez (BNT)
    // ----------------------------

function addLiquidity(uint256 BNTAmount) public onlyOwner nonReentrant {
    require(BNTAmount > 0, "BNTAmount must be > 0");
    require(BNT.allowance(msg.sender, address(this)) >= BNTAmount, "Insufficient allowance");

    // Transfere BNT real do owner para o contrato
    uint256 previousBalance = BNT.balanceOf(address(this));
    BNT.safeTransferFrom(msg.sender, address(this), BNTAmount);
    uint256 newBalance = BNT.balanceOf(address(this));
    uint256 received = newBalance - previousBalance;

    require(received == BNTAmount, "BNT transfer mismatch");
    BNTBalance += received;

    // Calcula BWT a mintar com validação extra
    uint256 BeamAmount = (received * connectorWeight) / 10000;
    require(BeamAmount > 0, "BeamAmount must be > 0");
    require(totalSupply() + BeamAmount <= MAX_TOTAL_SUPPLY, "Exceeds max supply");

    _mint(address(this), BeamAmount);

    emit LiquidityAdded(received, BeamAmount);
}



    // ----------------------------
    //      Swaps Bancor
    // ----------------------------

    function swapToBNT(address token, uint256 tokenAmount) internal returns (uint256) {
        require(bancorSwapContract != address(0), "Bancor Swap Contract not set");
        require(token != address(0), "Invalid token address");
        require(tokenAmount > 0, "Token amount must be > 0");

        if (token == ETH_ADDRESS) {
            // Swap ETH directly (send msg.value)
            (bool success, bytes memory data) = bancorSwapContract.call{value: tokenAmount}(
                abi.encodeWithSignature(
                    "tradeBySourceAmount(address,address,uint256,uint256,uint256,address)",
                    ETH_ADDRESS,          // sourceToken
                    address(BNT),         // targetToken
                    tokenAmount,
                    1,
                    block.timestamp + 300,
                    address(this)
                )
            );
            require(success && data.length > 0, "Swap failed or invalid data");
            uint256 bntReceived = abi.decode(data, (uint256));
            return bntReceived;
        } else {
            IERC20 tokenContract = IERC20(token);
            tokenContract.approve(bancorSwapContract, tokenAmount);

            (bool success, bytes memory data) = bancorSwapContract.call(
                abi.encodeWithSignature(
                    "tradeBySourceAmount(address,address,uint256,uint256,uint256,address)",
                    token,
                    address(BNT),
                    tokenAmount,
                    1,
                    block.timestamp + 300,
                    address(this)
                )
            );
            require(success && data.length > 0, "Swap failed or invalid data");
            uint256 bntReceived = abi.decode(data, (uint256));
            return bntReceived;
        }
    }

    // ----------------------------
    //  Funções de Public Sale (BNT)
    // ----------------------------

    function adjustPrice() public onlyOwner {
        require(currentSalePhase == SalePhase.PublicSale, "Dynamic pricing only in Public Sale");
        uint256 liquidityBWT = balanceOf(address(this));
        require(liquidityBWT > 0, "No liquidity BWT available");
        uint256 price = getCurrentPrice();
        emit PriceAdjusted(price);
    }

    function buyBeam(uint256 bntAmount) public nonReentrant gasPriceValid {
        require(currentSalePhase == SalePhase.PublicSale, "Buying allowed only in Public Sale");
        require(bntAmount > 0, "Amount must be > 0");

        BNT.safeTransferFrom(msg.sender, address(this), bntAmount);
        BNTBalance += bntAmount;

        uint256 liquidityBWT = balanceOf(address(this));
        require(liquidityBWT > 0, "No BWT liquidity available");

        uint256 price = getCurrentPrice();
        require(price > 0, "Invalid price calculation");

        uint256 beamAmount = bntAmount / price;
        require(beamAmount > 0, "Beam amount is zero");
        require(liquidityBWT >= beamAmount, "Not enough BWT in pool");
        require(purchaseLimit >= beamAmount, "Over purchase limit");
        _checkAndUpdateDailyLimit(msg.sender, beamAmount);

        totalBeamPurchasedByUser[msg.sender] += beamAmount;
        totalTokensSold += beamAmount;
        _transfer(address(this), msg.sender, beamAmount);

        uint256 bntFee = (bntAmount * feePercentage) / 100;
        uint256 bntNet = bntAmount - bntFee;

        BNT.safeTransfer(feeCollector, bntFee);

        emit BeamBought(msg.sender, beamAmount, bntNet);
    }


   function sellBeam(uint256 beamAmount) public nonReentrant {
        require(currentSalePhase == SalePhase.PublicSale, "Selling allowed only in Public Sale");
        require(balanceOf(msg.sender) >= beamAmount, "Insufficient BEAM balance");

        uint256 liquidityBWT = balanceOf(address(this));
        require(liquidityBWT > 0, "No liquidity available");

        uint256 price = getCurrentPrice();
        require(price > 0, "Invalid price");

        uint256 bntAmount = beamAmount * price;
        require(bntAmount > 0, "Calculated BNT amount is zero");
        require(BNT.balanceOf(address(this)) >= bntAmount, "Insufficient BNT in contract");

       _transfer(msg.sender, address(this), beamAmount);
        BNT.safeTransfer(msg.sender, bntAmount);

        BNTBalance -= bntAmount;
        totalTokensSold -= beamAmount;

        emit BeamSold(msg.sender, beamAmount, bntAmount);
    }


    function buyBeamWithToken(address token, uint256 tokenAmount) public nonReentrant gasPriceValid {
        require(token != address(0), "Invalid token address");
        require(tokenAmount > 0, "Token amount must be > 0");

        IERC20(token).safeTransferFrom(msg.sender, address(this), tokenAmount);

        // Tenta converter o token arbitrário para BNT usando o contrato Bancor
        uint256 bntReceived = swapToBNT(token, tokenAmount);
        require(bntReceived > 0, "BNT conversion failed");

        BNTBalance += bntReceived;

        uint256 liquidityBWT = balanceOf(address(this));
        require(liquidityBWT > 0, "No BWT liquidity available");

        uint256 price = getCurrentPrice();
        require(price > 0, "Invalid price calculation");

        uint256 beamAmount = bntReceived / price;
        require(beamAmount > 0, "Beam amount is zero");
        require(liquidityBWT >= beamAmount, "Not enough BWT in pool");
        require(purchaseLimit >= beamAmount, "Over purchase limit");
        _checkAndUpdateDailyLimit(msg.sender, beamAmount);

        totalBeamPurchasedByUser[msg.sender] += beamAmount;
        totalTokensSold += beamAmount;

        _transfer(address(this), msg.sender, beamAmount);

        // deduct fee from BNT
        uint256 bntFee = (bntReceived * feePercentage) / 100;
        uint256 bntNet = bntReceived - bntFee;

        // retain bntFee in contract or transfer to feeCollector
        BNT.safeTransfer(feeCollector, bntFee);

        emit BeamBought(msg.sender, beamAmount, bntNet);
    }

    // ----------------------------
    //  Comprar BEAM com ETH
    // ----------------------------

    function buyBeamWithETH() external payable nonReentrant gasPriceValid {
        require(msg.value > 0, "No ETH sent");
        if (tx.gasprice > maxGasPrice) revert GasPriceTooHigh();

        // Swap ETH directly to BNT via Bancor
        uint256 bntReceived = swapToBNT(ETH_ADDRESS, msg.value);
        require(bntReceived > 0, "BNT conversion failed");

        BNTBalance += bntReceived;

        uint256 liquidityBWT = balanceOf(address(this));
        require(liquidityBWT > 0, "No BWT liquidity available");

        uint256 price = getCurrentPrice();
        require(price > 0, "Invalid price calculation");

        uint256 beamAmount = bntReceived / price;
        require(beamAmount > 0, "Beam amount is zero");
        require(liquidityBWT >= beamAmount, "Not enough BWT in pool");
        require(purchaseLimit >= beamAmount, "Over purchase limit");
        _checkAndUpdateDailyLimit(msg.sender, beamAmount);

        totalBeamPurchasedByUser[msg.sender] += beamAmount;
        totalTokensSold += beamAmount;

        // send full Beam to buyer
        _transfer(address(this), msg.sender, beamAmount);

        // deduct fee from BNT
        uint256 bntFee = (bntReceived * feePercentage) / 100;
        uint256 bntNet = bntReceived - bntFee;

        // retain bntFee in contract or transfer to feeCollector
        BNT.safeTransfer(feeCollector, bntFee);

        emit BeamBought(msg.sender, beamAmount, bntNet);
    }


    receive() external payable {
        revert("Direct ETH not accepted. Use buyBeamWithETH()");
    }

    // ----------------------------
    //       Preços / Util
    // ----------------------------

    function getLatestETHPrice() public view returns (uint256) {
        (, int price, , , ) = _priceFeed.latestRoundData();
        return uint256(price);
    }

    function getDynamicPublicSalePrice() public view returns (uint256) {
        // Exemplo: ajusta com base em totalTokensSold
        return basePublicSalePrice + (totalTokensSold / 100);
    }
    // ----------------------------
    //      Preço BWT em USD
    // ----------------------------
    /// @notice Retorna o preço atual de 1 BWT em USD (18 casas decimais)
    function getCurrentBeamPriceUSD() public view returns (uint256) {
        uint256 liquidityBWT = balanceOf(address(this));
        require(liquidityBWT > 0, "No BWT liquidity");

        uint256 bntPriceInETH = getLatestPrice(bntEthFeed); // 18 decimais
        uint256 ethPriceInUSD = getLatestPrice(ethUsdFeed); // 8 decimais (Chainlink padrão)

        uint256 bntPriceInUSD = (bntPriceInETH * ethPriceInUSD) / 1e8;
        uint256 bwtPriceInBNT = (BNTBalance * 1e18) / liquidityBWT;
        uint256 bwtPriceInUSD = (bwtPriceInBNT * bntPriceInUSD) / 1e18;

        return bwtPriceInUSD;
    }

    /// @notice Versão formatada: retorna valor inteiro com 2 casas decimais (ex: 0.05 USD → retorna 5)
    function getCurrentBeamPriceUSDFormatted() public view returns (uint256) {
        uint256 rawPrice = getCurrentBeamPriceUSD();
        uint256 formatted = (rawPrice * 100) / 1e18;
        return formatted;
    }

    /// @notice Lê um preço Chainlink (BNT/ETH ou ETH/USD)
    function getLatestPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        return uint256(price);
    }

    /// @notice obter preço atual
    function getCurrentPrice() internal view returns (uint256) {
        uint256 liquidityBWT = balanceOf(address(this));
        require(liquidityBWT > 0, "No BWT liquidity");
        uint256 price = BNTBalance / liquidityBWT;
        require(price > 0, "Invalid price");
        return price;
    }

    function _checkAndUpdateDailyLimit(address user, uint256 beamAmount) internal {
        if (purchasePeriod > 0) {
            if (block.timestamp > lastPurchaseTimestamp[user] + purchasePeriod) {
                // Period expired, reset counter
                tokensPurchasedInPeriod[user] = 0;
                lastPurchaseTimestamp[user] = block.timestamp;
            }
            require(tokensPurchasedInPeriod[user] + beamAmount <= dailyPurchaseLimit, "Exceeds daily purchase limit");
            tokensPurchasedInPeriod[user] += beamAmount;
        }
    }

    // ----------------------------
    //        Saque de Ether
    // ----------------------------

    function withdrawEther(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient contract balance");
        if (maxEtherWithdrawal > 0) {
            require(amount <= maxEtherWithdrawal, "Withdrawal exceeds max limit");
        }
        payable(owner()).sendValue(amount);
        emit EtherWithdrawn(owner(), amount);
    }

    function setMaxEtherWithdrawal(uint256 newLimit) external onlyOwner {
        maxEtherWithdrawal = newLimit;
    }

    // ----------------------------
    //    Avançar Fase de Venda
    // ----------------------------

    function advanceSalePhase() external onlyOwner {
        if (currentSalePhase == SalePhase.PrivateSale) {
            // Mint do que sobrou (se sobrou) diretamente para GBC_SA_POOL
            uint256 totalRemainingTokensPrivate =
                salePhaseDetails[SalePhase.PrivateSale].maxTokens - totalTokensSoldPrivateSale;
            if (totalRemainingTokensPrivate > 0) {
                _mint(GBC_SA_POOL, totalRemainingTokensPrivate);
                emit TokensTransferredToGBC(GBC_SA_POOL, totalRemainingTokensPrivate);
            }
        } else if (currentSalePhase == SalePhase.PrePublicSale) {
            // Bloqueia os tokens adquiridos pelos contribuintes
            lockPreSaleTokens();

            uint256 remainingPrePublicSaleTokens =
                salePhaseDetails[SalePhase.PrePublicSale].maxTokens - totalTokensSoldPrePublicSale;
            uint256 remainingBonusTokens = BONUS_TOKENS - totalBonusTokensDistributed;
            uint256 totalRemainingTokens = remainingPrePublicSaleTokens + remainingBonusTokens;

            if (totalRemainingTokens > 0) {
                _mint(GBC_SA_POOL, totalRemainingTokens);
                emit TokensTransferredToGBC(GBC_SA_POOL, totalRemainingTokens);
            }
        }

        if (currentSalePhase == SalePhase.PublicSale) revert("Cannot advance beyond Public Sale");

        currentSalePhase = SalePhase(uint256(currentSalePhase) + 1);
        emit PhaseAdvanced(currentSalePhase);
    }

    function updateSalePhaseTimes(SalePhase phase, uint256 newStartTime, uint256 newEndTime) external onlyOwner {
        require(newStartTime < newEndTime, "Start time must be before end time");
        salePhaseDetails[phase].startTime = newStartTime;
        salePhaseDetails[phase].endTime = newEndTime;
        emit SalePhaseUpdated(phase, newStartTime, newEndTime);
    }

    function updateMinimumInvestment(SalePhase phase, uint256 newMinTokens) external onlyOwner {
        require(newMinTokens > 0, "Minimum tokens must be > 0");
        salePhaseDetails[phase].minTokens = newMinTokens;
    }
    
    function updateMaximumInvestment(SalePhase phase, uint256 newMaxTokens) external onlyOwner {
        require(newMaxTokens > salePhaseDetails[phase].minTokens, "Maximum must be greater than minimum");
        salePhaseDetails[phase].maxTokens = newMaxTokens;
        emit MaximumInvestmentUpdated(phase, newMaxTokens);
    }

    function getGBCPoolBalance() external view returns (uint256) {
        return balanceOf(GBC_SA_POOL);
    }

    function transferToGBCPool(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be > 0");
        require(totalSupply() + amount <= MAX_TOTAL_SUPPLY, "Exceeds maximum total supply");
        _mint(GBC_SA_POOL, amount);
        emit TokensTransferredToGBC(GBC_SA_POOL, amount);
    }

    function getUnallocatedTokens(SalePhase phase) external view returns (uint256) {
        SalePhaseInfo memory phaseInfo = salePhaseDetails[phase];
        uint256 tokensSold;
        if (phase == SalePhase.PrivateSale) {
            tokensSold = totalTokensSoldPrivateSale;
        } else if (phase == SalePhase.PrePublicSale) {
            tokensSold = totalTokensSoldPrePublicSale;
        } else {
            tokensSold = totalTokensSold;
        }
        if (tokensSold >= phaseInfo.maxTokens) {
            return 0;
        }
        return phaseInfo.maxTokens - tokensSold;
    }
    
    function setPurchaseLimit(uint256 newLimit) external onlyOwner {
        purchaseLimit = newLimit;
        emit PurchaseLimitUpdated(newLimit);
    }

     function setDailyPurchaseLimit(uint256 newLimit) external onlyOwner {
        dailyPurchaseLimit = newLimit;
        emit DailyPurchaseLimitUpdated(newLimit);
    }

    function setPurchasePeriod(uint256 newPeriod) external onlyOwner {
        purchasePeriod = newPeriod;
        emit PurchasePeriodUpdated(newPeriod);
    }

    function setMaxGasPrice(uint256 _maxGasPrice) external onlyOwner {
        maxGasPrice = _maxGasPrice;
        emit MaxGasPriceUpdated(_maxGasPrice);
    }

    function setBancorSwapContract(address _swapContract) external onlyOwner {
        require(_swapContract != address(0), "Invalid address");
        require(_swapContract.code.length > 0, "Swap address must be a contract");
        bancorSwapContract = _swapContract;
        emit BancorSwapContractUpdated(_swapContract);
    }

    function setFeePercentage(uint256 newFee) external onlyOwner {
        require(newFee <= 100, "Fee too high");
        feePercentage = newFee;
        emit BuyFeeUpdated(newFee);
    }
    function setFeeCollector(address _collector) external onlyOwner {
        require(_collector != address(0), "Invalid address");
        feeCollector = _collector;
        emit FeeCollectorUpdated(_collector);
    }
    function setConnectorWeight(uint256 newConnectorWeight) external onlyOwner {
        connectorWeight = newConnectorWeight;
        emit ConnectorWeightUpdated(newConnectorWeight);
    }
}