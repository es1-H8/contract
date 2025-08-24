// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// OpenZeppelin ReentrancyGuard
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status == _NOT_ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
}

// OpenZeppelin IERC20 Interface
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// Aave Pool Interface
interface IAavePool {
    function flashLoan(
        address receiverAddress,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata interestRateModes,
        address onBehalfOf,
        bytes calldata params,
        uint16 referralCode
    ) external;
}

// Main ArbitrageFlashLoaner Contract
contract ArbitrageFlashLoaner is ReentrancyGuard {
    address public owner;

    event ArbitrageExecuted(address indexed tokenIn, address indexed tokenOut, uint256 amount);
    event OwnerUpdated(address indexed oldOwner, address indexed newOwner);
    event EtherWithdrawn(address indexed owner, uint256 amount);
    event TokenWithdrawn(address indexed owner, address indexed token, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function executeArbitrage(
        address tokenIn,
        address tokenOut,
        uint256 amount
    ) external payable nonReentrant {
        require(tokenIn != address(0) && tokenOut != address(0) && amount > 0, "Invalid parameters");

        // Aave V3 Pool address (corrected checksum for Sepolia testnet)
        IAavePool aavePool = IAavePool(0x87870bCa3F3fD6335C3f4C287ce32eECCa37696C);

        address[] memory assets = new address[](1);
        assets[0] = tokenIn;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        uint256[] memory interestRateModes = new uint256[](1);
        interestRateModes[0] = 0; // No debt

        bytes memory params = "";

        aavePool.flashLoan(
            address(this),
            assets,
            amounts,
            interestRateModes,
            address(this),
            params,
            0
        );

        emit ArbitrageExecuted(tokenIn, tokenOut, amount);
    }

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata
    ) external returns (bool) {
        require(initiator == address(this), "Invalid initiator");

        // Approve Aave pool to pull the repayment (amount + premium)
        for (uint i = 0; i < assets.length; i++) {
            uint256 totalOwed = amounts[i] + premiums[i];
            require(IERC20(assets[i]).approve(msg.sender, totalOwed), "Approval failed");
        }

        // Arbitrage logic would go here (e.g., swap on DEX, calculate profit)
        // For demonstration, we just approve repayment

        return true;
    }

    receive() external payable {}

    function setOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        address oldOwner = owner;
        owner = newOwner;
        emit OwnerUpdated(oldOwner, newOwner);
    }

    function withdrawEther() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No Ether to withdraw");
        payable(owner).transfer(balance);
        emit EtherWithdrawn(owner, balance);
    }

    function withdrawToken(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        require(token.transfer(owner, balance), "Token transfer failed");
        emit TokenWithdrawn(owner, tokenAddress, balance);
    }
}