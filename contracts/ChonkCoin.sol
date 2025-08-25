// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ChonkCoin
/// @notice An ERC-20 token with tax, liquidity, and burn fees on transfers
/// @dev Extends OpenZeppelin ERC20 and Ownable contracts
contract ChonkCoin is ERC20, Ownable {
    /// @notice Tax fee percentage applied on transfers (in basis points, e.g., 5 = 5%)
    uint256 public taxFee = 5;
    /// @notice Portion of tax fee allocated to liquidity (in basis points)
    uint256 public liquidityFee = 3;
    /// @notice Portion of tax fee allocated to burning (in basis points)
    uint256 public burnFee = 2;
    /// @notice Address where liquidity fees are sent
    address public liquidityWallet;

    /// @dev Maximum tax fee allowed (10%)
    uint256 private constant MAX_TAX_FEE = 10;

    /// @notice Emitted when fees are updated
    /// @param taxFee New total tax fee
    /// @param liquidityFee New liquidity fee portion
    /// @param burnFee New burn fee portion
    event FeesUpdated(uint256 taxFee, uint256 liquidityFee, uint256 burnFee);

    /// @notice Emitted when the liquidity wallet address is updated
    /// @param newWallet New liquidity wallet address
    event LiquidityWalletUpdated(address indexed newWallet);

    /// @notice Initializes the contract with an initial token supply
    /// @param initialSupply Initial token supply (without decimals)
    constructor(uint256 initialSupply) ERC20("ChonkCoin", "CHONK") Ownable(msg.sender) {
        liquidityWallet = msg.sender;
        _mint(msg.sender, initialSupply * 10**decimals());
    }

    /// @notice Updates token balances and applies fees during transfers
    /// @param from Sender address
    /// @param to Recipient address
    /// @param amount Amount of tokens to transfer
    /// @dev Overrides ERC20 _update to include fee logic
    function _update(address from, address to, uint256 amount) internal virtual override {
        // Perform the full transfer first
        super._update(from, to, amount);

        // Apply fees only on regular transfers (not minting or burning)
        if (from != address(0) && to != address(0) && taxFee > 0) {
            uint256 feeAmount = (amount * taxFee) / 100;
            uint256 liquidityAmount = (feeAmount * liquidityFee) / taxFee;
            uint256 burnAmount = (feeAmount * burnFee) / taxFee;

            // Transfer liquidity fee to liquidity wallet
            if (liquidityAmount > 0) {
                super._update(from, liquidityWallet, liquidityAmount);
            }

            // Burn the burn fee portion
            if (burnAmount > 0) {
                _burn(from, burnAmount);
            }
        }
    }

    /// @notice Sets new fee percentages
    /// @param _taxFee Total tax fee (in percentage)
    /// @param _liquidityFee Portion of tax fee for liquidity
    /// @param _burnFee Portion of tax fee for burning
    /// @dev Only callable by the owner
    function setFees(uint256 _taxFee, uint256 _liquidityFee, uint256 _burnFee) external onlyOwner {
        require(_taxFee <= MAX_TAX_FEE, "Tax fee exceeds maximum");
        require(_liquidityFee + _burnFee == _taxFee, "Sum of liquidity and burn fees must equal tax fee");
        require(_taxFee > 0 || (_liquidityFee == 0 && _burnFee == 0), "Invalid fee configuration");

        taxFee = _taxFee;
        liquidityFee = _liquidityFee;
        burnFee = _burnFee;

        emit FeesUpdated(_taxFee, _liquidityFee, _burnFee);
    }

    /// @notice Sets a new liquidity wallet address
    /// @param wallet New liquidity wallet address
    /// @dev Only callable by the owner
    function setLiquidityWallet(address wallet) external onlyOwner {
        require(wallet != address(0), "Invalid wallet address");
        liquidityWallet = wallet;
        emit LiquidityWalletUpdated(wallet);
    }
}