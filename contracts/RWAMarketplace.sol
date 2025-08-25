// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
// Local interface for VRF Coordinator
interface VRFCoordinatorV2Interface {
    function requestRandomWords(
        bytes32 keyHash,
        uint64 subId,
        uint16 requestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint256 requestId);
}
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RWAMarketplace is VRFConsumerBaseV2, Ownable {
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 subscriptionId;
    // Sepolia VRF Coordinator: https://docs.chain.link/vrf/v2/subscription/supported-networks
    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    // Sepolia keyHash: 200 gwei gas lane
    bytes32 keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint32 callbackGasLimit = 200000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 2;

    IERC20 public paymentToken; // Token for payments (e.g., USDC)
    struct Asset {
        uint256 id;
        address owner;
        uint256 price;
        uint256 yieldRate; // Annual yield percentage
        bool forSale;
        uint256 riskScore; // Determined by VRF
        uint256 createdAt; // Timestamp of asset creation
    }
    mapping(uint256 => Asset) public assets;
    mapping(uint256 => uint256) public requestIdToAssetId;
    uint256 public assetCounter;
    mapping(address => uint256) public yieldsAccrued;

    event AssetCreated(uint256 indexed assetId, address owner, uint256 price, uint256 riskScore);
    event AssetPurchased(uint256 indexed assetId, address buyer, uint256 price);
    event YieldDistributed(address indexed holder, uint256 amount);

    constructor(address _paymentToken, uint64 _subscriptionId, address _vrfCoordinator, bytes32 _keyHash) 
        VRFConsumerBaseV2(_vrfCoordinator) 
        Ownable() 
    {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        paymentToken = IERC20(_paymentToken);
        subscriptionId = _subscriptionId;
        vrfCoordinator = _vrfCoordinator;
        keyHash = _keyHash;
    }

    function createAsset(uint256 price) external {
        uint256 assetId = assetCounter++;
        assets[assetId] = Asset({
            id: assetId,
            owner: msg.sender,
            price: price,
            yieldRate: 5, // Default 5% yield
            forSale: true,
            riskScore: 0,
            createdAt: block.timestamp
        });
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        requestIdToAssetId[requestId] = assetId;
        emit AssetCreated(assetId, msg.sender, price, 0);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        uint256 assetId = requestIdToAssetId[requestId];
        uint256 riskScore = randomWords[0] % 100 + 1; // Risk score between 1 and 100
        assets[assetId].riskScore = riskScore;
        assets[assetId].yieldRate = calculateYieldRate(riskScore);
        emit AssetCreated(assetId, assets[assetId].owner, assets[assetId].price, riskScore);
    }

    function calculateYieldRate(uint256 riskScore) private pure returns (uint256) {
        // Higher risk = higher yield (5% to 10%)
        return 5 + (riskScore / 20);
    }

    function buyAsset(uint256 assetId) external {
        Asset storage asset = assets[assetId];
        require(asset.forSale, "Asset not for sale");
        require(paymentToken.transferFrom(msg.sender, asset.owner, asset.price), "Payment failed");
        asset.owner = msg.sender;
        asset.forSale = false;
        emit AssetPurchased(assetId, msg.sender, asset.price);
    }

    function distributeYields(uint256 assetId) external {
        Asset storage asset = assets[assetId];
        require(asset.owner == msg.sender, "Not asset owner");
        uint256 timeElapsed = block.timestamp - asset.createdAt;
        uint256 yield = (asset.price * asset.yieldRate * timeElapsed) / (100 * 365 days);
        yieldsAccrued[msg.sender] += yield;
        require(paymentToken.transfer(msg.sender, yield), "Yield distribution failed");
        asset.createdAt = block.timestamp; // Reset timestamp after yield distribution
        emit YieldDistributed(msg.sender, yield);
    }

    function setAssetForSale(uint256 assetId, uint256 price) external {
        require(assets[assetId].owner == msg.sender, "Not asset owner");
        assets[assetId].forSale = true;
        assets[assetId].price = price;
    }
}