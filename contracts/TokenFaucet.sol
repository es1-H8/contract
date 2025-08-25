/**
 *Submitted for verification at Etherscan.io on 2025-06-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract TokenFaucet is Ownable {
    IERC20 public immutable tokenContract;
    uint256 public tokenAmount;
    uint256 public tokensGiven;
    uint256 public pricePerTokenWei; // new: price in wei per 1 token (not scaled)

    mapping(address => bool) private claimed;

    event TokensDispensed(address indexed recipient, uint256 amount);
    event TokensPurchased(address indexed buyer, uint256 ethSpent, uint256 tokensReceived);

    constructor(IERC20 _tokenContract, uint256 _tokenAmount, uint256 _pricePerTokenWei) {
        require(address(_tokenContract) != address(0), "Invalid token address");
        require(_tokenAmount > 0, "Token amount must be greater than zero");
        require(_pricePerTokenWei > 0, "Token price must be greater than zero");

        tokenContract = _tokenContract;
        tokenAmount = _tokenAmount;
        pricePerTokenWei = _pricePerTokenWei;
    }

    function claimTokens() external payable {
        require(!claimed[msg.sender], "User has already claimed tokens");
        require(msg.value == pricePerTokenWei, "Incorrect ETH sent for airdrop claim");
        uint256 decimals = tokenContract.decimals();
        uint256 scaledAmount = tokenAmount; // tokenAmount is already in wei, no need to scale again
        require(tokenContract.balanceOf(address(this)) >= scaledAmount, "Insufficient token balance in faucet");
        claimed[msg.sender] = true;
        tokensGiven += tokenAmount / (10 ** decimals); // Convert back to base units for recordkeeping
        emit TokensDispensed(msg.sender, tokenAmount / (10 ** decimals));
        require(tokenContract.transfer(msg.sender, scaledAmount), "Token transfer failed");
    }

    function buyTokens() external payable {
        require(msg.value >= pricePerTokenWei, "Insufficient ETH sent: must send at least pricePerTokenWei");
        require(msg.value > 0, "No ETH sent");
        require(pricePerTokenWei > 0, "Token price not set");

        uint256 decimals = tokenContract.decimals();
        uint256 tokensToBuy = (msg.value * (10 ** decimals)) / pricePerTokenWei;

        require(tokenContract.balanceOf(address(this)) >= tokensToBuy, "Insufficient token balance in faucet");

        tokensGiven += tokensToBuy / (10 ** decimals); // for recordkeeping in base units
        emit TokensPurchased(msg.sender, msg.value, tokensToBuy);

        require(tokenContract.transfer(msg.sender, tokensToBuy), "Token transfer failed");
    }

    function setPrice(uint256 _pricePerTokenWei) external onlyOwner {
        require(_pricePerTokenWei > 0, "Price must be greater than zero");
        pricePerTokenWei = _pricePerTokenWei;
    }

    function withdrawTokens() external onlyOwner {
        uint256 balance = tokenContract.balanceOf(address(this));
        require(tokenContract.transfer(owner, balance), "Token withdrawal failed");
    }

    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function updateTokenAmount(uint256 _newTokenAmount) external onlyOwner {
        require(_newTokenAmount > 0, "Token amount must be greater than zero");
        tokenAmount = _newTokenAmount;
    }

    function hasClaimed(address user) external view returns (bool) {
        return claimed[user];
    }

    function resetClaim(address user) external onlyOwner {
        claimed[user] = false;
    }
}