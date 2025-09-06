// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title Crowdsale
/// @notice Base contract for managing a token crowdsale, allowing investors to purchase tokens with ETH
/// @dev Extends OpenZeppelin ReentrancyGuard and uses SafeERC20 for safe token transfers
/// @dev Borrowed from OpenZeppelin Crowdsale (v2.x) and upgraded to Solidity ^0.8.4
contract Crowdsale is Context, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice The token being sold
    IERC20 private _token;

    /// @notice Address where collected funds are forwarded
    address payable private _wallet;

    /// @notice Conversion rate: number of token units per wei
    uint256 private _rate;

    /// @notice Total amount of wei raised
    uint256 private _weiRaised;

    /// @notice Emitted when tokens are purchased
    /// @param purchaser Who paid for the tokens
    /// @param beneficiary Who received the tokens
    /// @param value Amount of wei paid
    /// @param amount Amount of tokens purchased
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /// @notice Initializes the crowdsale
    /// @param rate_ Number of token units a buyer gets per wei
    /// @param wallet_ Address where collected funds are forwarded
    /// @param token_ Address of the ERC-20 token being sold
    constructor(uint256 rate_, address payable wallet_, IERC20 token_) {
        require(rate_ > 0, "Crowdsale: rate is 0");
        require(wallet_ != address(0), "Crowdsale: wallet is the zero address");
        require(address(token_) != address(0), "Crowdsale: token is the zero address");

        _rate = rate_;
        _wallet = wallet_;
        _token = token_;
    }

    /// @notice Fallback function to allow direct ETH purchases
    /// @dev Calls buyTokens with the sender as the beneficiary
    receive() external payable {
        buyTokens(_msgSender());
    }

    /// @notice Returns the token being sold
    /// @return IERC20 interface of the token
    function token() public view returns (IERC20) {
        return _token;
    }

    /// @notice Returns the address where funds are collected
    /// @return Address payable where funds are forwarded
    function wallet() public view returns (address payable) {
        return _wallet;
    }

    /// @notice Returns the number of token units a buyer gets per wei
    /// @return Conversion rate
    function rate() public view returns (uint256) {
        return _rate;
    }

    /// @notice Returns the total amount of wei raised
    /// @return Amount of wei raised
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    /// @notice Allows purchasing tokens with ETH
    /// @param beneficiary Recipient of the token purchase
    /// @dev Non-reentrant to prevent reentrancy attacks
    function buyTokens(address beneficiary) public payable nonReentrant {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        // Calculate token amount to be delivered
        uint256 tokens = _getTokenAmount(weiAmount);

        // Update state
        _weiRaised = _weiRaised + weiAmount;

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        _updatePurchasingState(beneficiary, weiAmount);
        _forwardFunds();
        _postValidatePurchase(beneficiary, weiAmount);
    }

    /// @notice Validates an incoming purchase
    /// @param beneficiary Address performing the token purchase
    /// @param weiAmount Value in wei involved in the purchase
    /// @dev Virtual to allow extensions (e.g., capped crowdsale)
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view virtual {
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
    }

    /// @notice Validates an executed purchase
    /// @param beneficiary Address performing the token purchase
    /// @param weiAmount Value in wei involved in the purchase
    /// @dev Virtual to allow extensions; currently a no-op
    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal view virtual {
        // No-op
    }

    /// @notice Delivers tokens to the beneficiary
    /// @param beneficiary Address receiving the tokens
    /// @param tokenAmount Number of tokens to be delivered
    /// @dev Virtual to allow custom token delivery mechanisms
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal virtual {
        _token.safeTransfer(beneficiary, tokenAmount);
    }

    /// @notice Executes a validated purchase
    /// @param beneficiary Address receiving the tokens
    /// @param tokenAmount Number of tokens to be purchased
    /// @dev Calls _deliverTokens to handle token transfer
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _deliverTokens(beneficiary, tokenAmount);
    }

    /// @notice Updates internal state after a purchase
    /// @param beneficiary Address receiving the tokens
    /// @param weiAmount Value in wei involved in the purchase
    /// @dev Virtual to allow tracking contributions or other state changes
    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal virtual {
        // No-op
    }

    /// @notice Converts wei to token amount
    /// @param weiAmount Value in wei to be converted
    /// @return Number of tokens that can be purchased
    /// @dev Virtual to allow custom rate calculations
    function _getTokenAmount(uint256 weiAmount) internal view virtual returns (uint256) {
        return weiAmount * _rate;
    }

    /// @notice Forwards collected ETH to the wallet
    /// @dev Uses low-level transfer for gas efficiency
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
}