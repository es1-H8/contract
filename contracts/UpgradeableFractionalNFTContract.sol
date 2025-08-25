// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

// Removed redundant interface IHASHAStableToken to reduce contract size
interface IHASHAStableToken is IERC20 {
    function mintTokens(address to, uint256 amount) external;
}

contract UpgradeableFractionalNFTContract is
    Initializable,
    ERC20Upgradeable,
    OwnableUpgradeable,
    ERC20PermitUpgradeable,
    ERC721HolderUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bool public isPolygonChain;

    struct FractionalizedNFT {
        IERC721 collection;
        uint256 tokenId;
        uint256 tokenAmount;
        address originalFractionalizer;
        bool forSale;
        uint256 pricePerFraction;
        uint256 remainingFractions;
    }

    IHASHAStableToken public HASHATOKEN;
    mapping(address => mapping(uint256 => FractionalizedNFT)) public fractionalizedNFTs;
    mapping(address => bool) public supportedTokens;
    mapping(address => mapping(uint256 => uint256)) public nftFractionSupply;
    mapping(address => mapping(uint256 => mapping(address => uint256))) public nftFractionBalances;

    // Consolidated events to reduce contract size
    event NFTFractionalized(
        address indexed collection,
        uint256 indexed tokenId,
        uint256 tokenAmount,
        uint256 fractionAmount,
        uint256 pricePerFraction,
        address indexed fractionalizer,
        bool withRole
    );
    event FractionPurchased(
        address indexed buyer,
        address indexed collection,
        uint256 indexed tokenId,
        uint256 fractionAmount,
        address tokenUsed,
        uint256 totalPrice
    );
    event Redeemed(
        address indexed redeemer,
        address indexed collection,
        uint256 indexed tokenId,
        uint256 burnedAmount
    );
    event TokenSupportUpdated(address token, bool isSupported);
    event MinterRoleUpdated(address indexed account, bool granted, address indexed admin);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _HASHATOKEN) public initializer {
        __ERC20_init("Fractional NFT Token", "FNT");
        __ERC20Permit_init("Fractional NFT Token");
        __Ownable_init(msg.sender);
        __AccessControl_init();
        __Pausable_init();
        __ReentrancyGuard_init();

        HASHATOKEN = IHASHAStableToken(_HASHATOKEN);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        supportedTokens[address(0)] = true; // Native token (ETH/MATIC)
        supportedTokens[0xE410d33FeD4593Aa075974bc4A351aE7215E0C63] = true; // Ethereum mainnet token
    }

    // Combined grant/revoke minter role into one function to reduce code duplication
    function updateMinterRole(address account, bool grant) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (grant) {
            _grantRole(MINTER_ROLE, account);
        } else {
            _revokeRole(MINTER_ROLE, account);
        }
        emit MinterRoleUpdated(account, grant, msg.sender);
    }

    function setSupportedTokens(address token, bool isSupported) external onlyOwner {
        supportedTokens[token] = isSupported;
        supportedTokens[address(0)] = true; // Ensure native token support
        emit TokenSupportUpdated(token, isSupported);
    }

    // Consolidated mintAndFractionalize functions into one with a role check
    function mintAndFractionalize(
        address _collection,
        uint256 _tokenId,
        uint256 _tokenAmount,
        uint256 _fractionAmount,
        uint256 _pricePerFraction,
        bool useMinterRole
    ) external whenNotPaused nonReentrant {
        require(_tokenAmount > 0, "Token amount must be > 0");
        if (useMinterRole) {
            require(!isPolygonChain, "Minter role not allowed on Polygon");
            require(hasRole(MINTER_ROLE, msg.sender), "Missing MINTER_ROLE");
        }

        FractionalizedNFT storage fractionalizedNFT = fractionalizedNFTs[_collection][_tokenId];
        require(fractionalizedNFT.tokenAmount == 0, "NFT already fractionalized");

        fractionalizedNFT.collection = IERC721(_collection);
        fractionalizedNFT.collection.safeTransferFrom(msg.sender, address(this), _tokenId);

        fractionalizedNFT.tokenId = _tokenId;
        fractionalizedNFT.tokenAmount = _tokenAmount;
        fractionalizedNFT.pricePerFraction = _pricePerFraction;
        fractionalizedNFT.forSale = true;
        fractionalizedNFT.originalFractionalizer = msg.sender;

        require(_fractionAmount > 0, "Fraction amount must be > 0");
        require(_fractionAmount <= _tokenAmount, "Fraction amount exceeds token amount");

        uint256 fractionalSupply = _fractionAmount * 10 ** 18;
        if (useMinterRole) {
            HASHATOKEN.mintTokens(msg.sender, fractionalSupply);
        } else {
            _mint(address(this), fractionalSupply);
        }
        nftFractionSupply[_collection][_tokenId] = fractionalSupply;
        fractionalizedNFT.remainingFractions = fractionalSupply;

        emit NFTFractionalized(
            _collection,
            _tokenId,
            _tokenAmount,
            _fractionAmount,
            _pricePerFraction,
            msg.sender,
            useMinterRole
        );
    }

    // Consolidated purchase functions into one with payment type check
    function purchaseFraction(
        address _collection,
        uint256 _tokenId,
        uint256 _fractionAmount,
        address _erc20Token,
        uint256 _erc20Price
    ) external payable whenNotPaused nonReentrant {
        FractionalizedNFT storage fractionalizedNFT = fractionalizedNFTs[_collection][_tokenId];
        require(fractionalizedNFT.forSale, "Fraction not for sale");
        require(_fractionAmount > 0, "Must purchase at least 1 fraction");

        uint256 amountToBuy = _fractionAmount * 10 ** 18;
        require(fractionalizedNFT.remainingFractions >= amountToBuy, "Not enough fractions available");

        uint256 totalPrice = _fractionAmount * fractionalizedNFT.pricePerFraction;

        if (_erc20Token == address(0)) {
            require(msg.value == totalPrice, "Incorrect ETH amount");
            payable(fractionalizedNFT.originalFractionalizer).transfer(msg.value);
        } else {
            require(supportedTokens[_erc20Token], "Token not supported");
            require(_erc20Price == totalPrice, "Incorrect token price");
            IERC20(_erc20Token).transferFrom(msg.sender, fractionalizedNFT.originalFractionalizer, _erc20Price);
        }

        fractionalizedNFT.remainingFractions -= amountToBuy;
        if (fractionalizedNFT.remainingFractions == 0) {
            fractionalizedNFT.forSale = false;
        }

        _transfer(address(this), msg.sender, amountToBuy);
        nftFractionBalances[_collection][_tokenId][msg.sender] += amountToBuy;

        emit FractionPurchased(
            msg.sender,
            _collection,
            _tokenId,
            _fractionAmount,
            _erc20Token,
            _erc20Token == address(0) ? msg.value : _erc20Price
        );
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function redeem(address _collection, uint256 _tokenId) external nonReentrant whenNotPaused {
        FractionalizedNFT storage fNFT = fractionalizedNFTs[_collection][_tokenId];
        require(fNFT.tokenAmount > 0, "NFT not fractionalized");

        uint256 nftSupply = nftFractionSupply[_collection][_tokenId];
        require(nftSupply > 0, "Invalid fraction supply");
        require(
            nftFractionBalances[_collection][_tokenId][msg.sender] == nftSupply,
            "Must own all fractions"
        );

        _burn(msg.sender, nftSupply);
        fNFT.collection.safeTransferFrom(address(this), msg.sender, _tokenId);

        delete fractionalizedNFTs[_collection][_tokenId];
        delete nftFractionSupply[_collection][_tokenId];
        delete nftFractionBalances[_collection][_tokenId][msg.sender];

        emit Redeemed(msg.sender, _collection, _tokenId, nftSupply);
    }
}