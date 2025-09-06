/**
 *Submitted for verification at Etherscan.io on 2025-08-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * DeutscheBankConvertRWA License Agreement
 * 
 * Version 4.0.2.2025
 * 
 * IMPORTANT NOTICE: This License Agreement ("Agreement") is a legal agreement between you ("Licensee") and DeutscheBankConvert Corporation ("Licensor") for the use of the DeutscheBankConvert 
 * Smart Contract Platform ("Platform"). By deploying or interacting with this smart contract ("Contract"), you agree to be bound by the terms of this Agreement.
 * 
 * 1. Definitions:
 *    a. "Authorized User" refers to an individual or entity explicitly permitted by Licensor to access and utilize the Platform.
 *    b. "Proprietary Data" refers to any data, algorithm, code, or intellectual property provided by Licensor under this Agreement.
 *    c. "Prohibited Use" includes, but is not limited to, any action violating applicable laws, infringing intellectual property rights, or compromising the security and integrity of the Platform.
 * 
 * 2. Grant of License:
 *    a. Subject to the terms and conditions herein, Licensor grants Licensee a limited, non-exclusive, non-transferable, revocable license to use the Contract for the purposes intended and authorized by Licensor.
 *    b. The license does not permit any modification, reverse engineering, or unauthorized reproduction of the Contract code.
 *    c. Any unauthorized use of the Contract will result in immediate termination of this license.
 * 
 * 3. Ownership:
 *    a. The Contract and all associated intellectual property rights remain the sole and exclusive property of Licensor.
 *    b. Licensee acknowledges and agrees that no ownership rights are transferred under this Agreement.
 * 
 * 4. Usage Restrictions:
 *    a. The Platform must not be used for any unlawful activities, including but not limited to money laundering, terrorism financing, or fraudulent schemes.
 *    b. Any deployment of the Contract for high-risk or speculative financial instruments requires prior written approval from Licensor.
 *    c. Licensee is prohibited from using the Platform to generate unauthorized derivative works.
 * 
 * 5. Compliance and Auditing:
 *    a. Licensee agrees to comply with all applicable laws and regulations, including those pertaining to anti-money laundering (AML) and know-your-customer (KYC) requirements.
 *    b. Licensor reserves the right to audit any and all transactions processed through the Contract to ensure compliance.
 *    c. Licensee agrees to provide timely access to relevant data upon Licensor's request for auditing purposes.
 * 
 * 6. Limitation of Liability:
 *    a. Licensor is not responsible for any direct, indirect, incidental, or consequential damages arising from the use of the Platform.
 *    b. The Contract is provided "as is" without warranties of any kind, either express or implied, including but not limited to merchantability or fitness for a particular purpose.
 * 
 * 7. Termination:
 *    a. Licensor reserves the right to terminate this Agreement and revoke the license at any time without notice in the event of a breach of any terms herein.
 *    b. Upon termination, Licensee must cease all use of the Contract and delete any related materials.
 * 
 * 8. Governing Law and Dispute Resolution:
 *    a. This Agreement shall be governed by and construed in accordance with the laws of the Federal Republic of Germany.
 *    b. Any disputes arising out of or in connection with this Agreement shall be resolved through arbitration in Frankfurt am Main, Germany, under the rules of the International Chamber of Commerce (ICC).
 * 
 * 9. Miscellaneous:
 *    a. This Agreement constitutes the entire understanding between the parties and supersedes all prior agreements or understandings related to the subject matter hereof.
 *    b. If any provision of this Agreement is found to be unenforceable, the remaining provisions shall remain in full force and effect.
 *    c. Licensor reserves the right to amend this Agreement at any time, with amendments taking effect upon notice to Licensee.
 *
 * 10. Confidentiality:
 *
 *    a. Licensee acknowledges that the Platform and associated documentation contain proprietary and confidential information of Licensor.
 *    b. Licensee agrees to hold such information in strict confidence and not to disclose it to any third party without Licensor's prior written consent.
 *    c. This confidentiality obligation survives the termination of this Agreement.
 *
 * 11. Data Privacy:
 *    a. Licensee is responsible for ensuring compliance with all applicable data privacy laws and regulations regarding any personal data processed through the Platform.
 *    b. Licensor is not responsible for any data privacy breaches or violations caused by Licensee's use of the Platform.
 *
 * 12. Export Control:
 *   a. Licensee agrees to comply with all applicable export control laws and regulations in connection with the use of the Platform.
 *   b. Licensee shall not export or re-export the Platform or any related materials to any country or individual in violation of such laws and regulations. 
 *
 * 13. Financial Information:
 *      The Licensee acknowledges that the use of the Deutsche Bank AG Convert Smart Contract Platform may involve the processing of financial data. The Licensee is solely responsible for 
 *      ensuring the security and confidentiality of all financial information transmitted or stored on the Platform. Deutsche Bank AG Convert Corporation disclaims any responsibility for data 
 *      breaches or unauthorized access to financial information resulting from the Licensee's negligence or failure to implement adequate security measures, as outlined in ISO/IEC 27001 standards 
 *      [International Organization for Standardization, ISO/IEC 27001:2013].
 *      Furthermore, the Licensee understands that Deutsche Bank AG Convert Corporation does not provide financial advice or guarantee any specific financial outcome from the use of the Platform. 
 *      The Licensee is solely responsible for conducting due diligence and evaluating the risks associated with any financial transactions executed through the Contract. The utilization of the 
 *      platform for trading in regulated financial instruments may require compliance with MiFID II regulations [Directive 2014/65/EU], and the Licensee is responsible for ensuring such compliance.
 *      The Licensee warrants that any financial information provided to the Platform is accurate, complete, and obtained in compliance with all applicable laws and regulations. The Licensor reserves 
 *      the right to suspend or terminate the Licensee's access to the Platform if it discovers any fraudulent or misleading financial information. The Licensee is obliged to report any suspected 
 *      irregularities or breaches of security related to financial data to the Licensor immediately.
 *      Deutsche Bank AG Convert Corporation maintains robust security protocols commensurate with industry best practices to protect the integrity of the Platform's infrastructure. 
 *      However, the Licensee acknowledges that no system is entirely immune to security threats, and the Licensor cannot guarantee absolute security. The Licensee is encouraged to implement 
 *      multi-factor authentication and regularly update security protocols in accordance with recommendations from cybersecurity agencies such as the National Institute of Standards and Technology 
 *      (NIST) [NIST Special Publication 800-53].
 *      The Licensee's attention is drawn to the legal implications of processing financial data under the General Data Protection Regulation (GDPR) [Regulation (EU) 2016/679]. The Licensee is the 
 *      data controller for any personal data processed through the Platform and must comply with all GDPR requirements, including obtaining valid consent, providing data subject access rights, 
 *      and implementing appropriate data protection measures.
 *      Deutsche Bank AG Convert Corporation logs all transactions and activities conducted on the Platform for audit and security purposes, as per regulatory requirements. The Licensee consents 
 *      to such logging and monitoring activities. Data retention policies adhere to applicable legal and regulatory guidelines, including those stipulated by the Markets in Financial Instruments 
 *      Directive (MiFID II).
 * 
 * 14. Updates and Maintenance:
 *  a. Licensor may, at its sole discretion, provide updates or maintenance for the Contract.
 *  b. Licensor is not obligated to provide any specific level of support or maintenance.
 *  c. Licensee acknowledges that updates may require changes to its systems or processes.
 *
 * 15. Legal Notices
 *      Copyright Swift © 2025. All rights reserved.
 *
 * 16. Financial Information:
 *      Sender: FND GERMAN RE GMBH
 *      IBAN: DE07200700000578966400
 *      BIC (SWIFT): DEUTDEHH
 *      Receiver: INTERACTIVE BROKERS LLC
 *      IBAN: DE82501108006161535387
 *      BIC (SWIFT): CHASDEFX
 *      Transaction Reference Number (TRN): D933962083795906
 *      Amount: 4877997888,00 EURO
 *      
 * 17. Conversion information:
 *      Master Wallet Sender  :     0xa4D1130cf61Cbe518b19EdeD24B9114BCcED0E8D 
 *      Master Wallet Receiver:     0x3e5E1D768c6c97a937eABecECE19aF804EcdBa2e
 *      Base amount           :     4877997888,00 EURO
 *      Converted amount      :     1532684.00 RWA-TOKEN
 *      Conversion rate       :     1:3182.65
 *      Conversion date       :     2025-08-05
 */

// Sources flattened with hardhat v2.22.16 https://hardhat.org

// File @openzeppelin/contracts/interfaces/draft-IERC6093.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/utils/Context.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/token/ERC20/ERC20.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/ERC20.sol)

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
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
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
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

pragma solidity ^0.8.26;



contract RWAConvertToken is ERC20 {
    address public owner;
    address public rwaAddress;

    uint8 public constant DECIMALS = 6;

    event Conversion(uint256 balance, bytes details);
    event SwiftCheck(string trnNumber, uint256 amount, address indexed to);
    event SwiftAPICall(string trnNumber, string message);
    event RWATransferAttempt(address from, address to, uint256 amount, string status);
    event DeutscheBankTransfer(address indexed from, address indexed to, uint256 amount);
   
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
    /** https://www.binance.com/ru/trade/ETH_EUR?type=spot
    */
    constructor(address _rwaAddress) ERC20("ETH RWA TOKEN", " ETH-RWA-TOKEN") {
        require(_rwaAddress != address(0), "RWA-Toten address cannot be zero");
        owner = msg.sender;
        rwaAddress = _rwaAddress;
        _mint(msg.sender, 1532684 * 10 ** decimals());
    }

    function DeutscheBankConvertRWA (uint256 amount, string calldata details) external {
        require(amount > 0, "Amount must be greater than zero");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        emit RWATransferAttempt(msg.sender, rwaAddress, amount, "Attempting transfer to RWA-Toten contract");

        bool success = false; 
        if (success) {
            emit RWATransferAttempt(msg.sender, rwaAddress, amount, "RWA-Toten transfer failed");
        } else {
            emit RWATransferAttempt(msg.sender, rwaAddress, amount, "RWA-Toten transfer successful");
        }

        bytes memory detailsBytes = bytes(details);
        emit Conversion(amount, detailsBytes);
    }

 /**
 TRN: D933962083795906; RELEASE CODE: 6CFKQKJW8PFM0LBH
 */

    function swiftCheck(string calldata trnNumber, uint256 amount, address to) external onlyOwner {
        require(to != address(0), "Recipient address cannot be zero");
        require(amount > 0, "Amount must be greater than zero");
        require(bytes(trnNumber).length == 16, "Invalid TRN number");

        emit SwiftAPICall(trnNumber, "Request sent to SWIFT.COM for validation");

        _mint(to, amount);
        emit SwiftCheck(trnNumber, amount, to);
    }

    function deutscheBankTransfer(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Recipient address cannot be zero");
        require(amount > 0, "Amount must be greater than zero");
        require(balanceOf(owner) >= amount, "Insufficient balance");

        _transfer(owner, to, amount);
        emit DeutscheBankTransfer(owner, to, amount);
    }

    function uintToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

}