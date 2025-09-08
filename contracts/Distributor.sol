// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "erc721a-upgradeable/contracts/ERC721AUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract QuadsPokerWithDistributor is ERC721AUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    uint256 public maxSupply;
    uint256 public pricePerToken;
    string prefixURI;
    bool public transferEnabled;
    uint256 public amountPerUser;

    event Distribution(address[] recipients, uint256 amount);
    event AmountUpdated(uint256 newAmount);
    event Received(address sender, uint256 amount);

    constructor() {
        _disableInitializers();
    }

    function initialize() public initializerERC721A initializer {
        __ERC721A_init("QuadsPoker", "quadspoker");
        __UUPSUpgradeable_init();
        __Ownable_init();

        maxSupply = 10000;
        pricePerToken = 0.05 ether;
        transferEnabled = false;
        amountPerUser = 0.0271 ether; // Default value from Distributor constructor
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    function publicMint(uint256 quantity) public payable {
        require(totalSupply() + quantity <= maxSupply, "Sold Out!");
        require(msg.value >= quantity * pricePerToken, "Insufficient funds!");
        _mint(msg.sender, quantity);
    }

    function setPublicMintPrice(uint256 _price) external onlyOwner {
        pricePerToken = _price;
    }

    function setMaxSupply(uint256 _quantity) external onlyOwner {
        maxSupply = _quantity;
    }

    function setTransferEnabled(bool _enabled) external onlyOwner {
        transferEnabled = _enabled;
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal override {
        if (!transferEnabled && from != address(0) && to != address(0)) {
            revert("Transfers are disabled");
        }
        super._beforeTokenTransfers(from, to, startTokenId, quantity);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return prefixURI;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(_tokenId), "Token does not exist");
        return super.tokenURI(_tokenId);
    }

    function setBaseURI(string calldata _prefixURI) external onlyOwner {
        prefixURI = _prefixURI;
    }

    function batchAirdrop(address[] calldata recipients) external onlyOwner {
        require(recipients.length > 0, "Empty recipients array");
        uint256 totalAmount = amountPerUser * recipients.length;
        require(address(this).balance >= totalAmount, "Insufficient balance");

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            require(recipient != address(0), "Invalid recipient address");
            (bool success, ) = recipient.call{value: amountPerUser}("");
            require(success, "Transfer failed");
        }

        emit Distribution(recipients, amountPerUser);
    }

    function updateAmount(uint256 _newAmount) external onlyOwner {
        require(_newAmount > 0, "Invalid amount");
        amountPerUser = _newAmount;
        emit AmountUpdated(_newAmount);
    }

    function withdraw(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Invalid amount");
        require(_amount <= address(this).balance, "Insufficient balance");
        (bool success, ) = owner().call{value: _amount}("");
        require(success, "Transfer failed");
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}