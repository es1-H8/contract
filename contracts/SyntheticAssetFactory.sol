//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Synthetic Asset Factory with Chainlink Price Feeds
contract SyntheticAssetFactory is Ownable {
    struct SyntheticAsset {
        address token;
        address priceFeed;
        uint256 totalSupply;
        bool active;
    }
    mapping(uint256 => SyntheticAsset) public assets;
    uint256 public assetCounter;
    mapping(address => mapping(uint256 => uint256)) public balances;

    event AssetCreated(uint256 indexed assetId, address token, address priceFeed);
    event AssetMinted(uint256 indexed assetId, address user, uint256 amount);

    constructor(address initialOwner) Ownable(initialOwner) {}

    function createSyntheticAsset(string memory name, string memory symbol, address priceFeed) external onlyOwner {
        require(priceFeed != address(0), "Invalid price feed");
        SyntheticToken token = new SyntheticToken(name, symbol, address(this));
        uint256 assetId = assetCounter++;
        assets[assetId] = SyntheticAsset({
            token: address(token),
            priceFeed: priceFeed,
            totalSupply: 0,
            active: true
        });
        emit AssetCreated(assetId, address(token), priceFeed);
    }

    function mintSyntheticAsset(uint256 assetId, uint256 amount) external payable {
        SyntheticAsset storage asset = assets[assetId];
        require(asset.active, "Asset not active");
        (, int256 price,,,) = AggregatorV3Interface(asset.priceFeed).latestRoundData();
        require(price > 0, "Invalid price data");
        uint256 requiredCollateral = (amount * uint256(price)) / 1e18;
        require(msg.value >= requiredCollateral, "Insufficient collateral");
        asset.totalSupply = asset.totalSupply + amount;
        balances[msg.sender][assetId] = balances[msg.sender][assetId] + amount;
        SyntheticToken(asset.token).mint(msg.sender, amount);
        emit AssetMinted(assetId, msg.sender, amount);
    }

    function redeemSyntheticAsset(uint256 assetId, uint256 amount) external {
        SyntheticAsset storage asset = assets[assetId];
        require(asset.active, "Asset not active");
        require(balances[msg.sender][assetId] >= amount, "Insufficient balance");
        (, int256 price,,,) = AggregatorV3Interface(asset.priceFeed).latestRoundData();
        require(price > 0, "Invalid price data");
        uint256 collateralToReturn = (amount * uint256(price)) / 1e18;
        asset.totalSupply = asset.totalSupply - amount;
        balances[msg.sender][assetId] = balances[msg.sender][assetId] - amount;
        SyntheticToken(asset.token).burn(msg.sender, amount);
        payable(msg.sender).transfer(collateralToReturn);
    }
}

contract SyntheticToken is ERC20 {
    address public factory;

    constructor(string memory name, string memory symbol, address _factory) ERC20(name, symbol) {
        factory = _factory;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == factory, "Only factory can mint");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        require(msg.sender == factory, "Only factory can burn");
        _burn(from, amount);
    }
}