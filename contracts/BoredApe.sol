// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// OpenZeppelin ERC721
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

abstract contract ERC721 is Context, IERC721, IERC721Metadata {
    string private _name;
    string private _symbol;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "ERC721: invalid token ID");
        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()), "ERC721: approve caller is not owner nor approved");
        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_ownerOf(tokenId) != address(0), "ERC721: invalid token ID");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");
        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver");
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, data), "ERC721: transfer to non ERC721Receiver");
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(_owners[tokenId] == address(0), "ERC721: token already minted");
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");
        _approve(address(0), tokenId);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory) {
                return false;
            }
        }
        return true;
    }
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// OpenZeppelin ReentrancyGuard
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status == _NOT_ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

// OpenZeppelin PaymentSplitter
contract PaymentSplitter {
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 private _totalShares;
    uint256 private _totalReleased;
    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _released;
    address[] private _payees;

    constructor(address[] memory payees, uint256[] memory shares_) payable {
        require(payees.length == shares_.length, "PaymentSplitter: payees and shares length mismatch");
        require(payees.length > 0, "PaymentSplitter: no payees");
        for (uint256 i = 0; i < payees.length; i++) {
            _addPayee(payees[i], shares_[i]);
        }
    }

    receive() external payable virtual {
        emit PaymentReceived(msg.sender, msg.value);
    }

    function release(address payable account) public virtual {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");
        uint256 totalReceived = address(this).balance + _totalReleased;
        uint256 payment = (totalReceived * _shares[account]) / _totalShares - _released[account];
        require(payment != 0, "PaymentSplitter: account is not due payment");
        _released[account] += payment;
        _totalReleased += payment;
        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    function _addPayee(address account, uint256 shares_) private {
        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(_shares[account] == 0, "PaymentSplitter: account already has shares");
        _payees.push(account);
        _shares[account] = shares_;
        _totalShares += shares_;
        emit PayeeAdded(account, shares_);
    }
}

library Address {
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// OpenZeppelin MerkleProof
library MerkleProof {
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }
}

// OpenZeppelin Counters
library Counters {
    struct Counter {
        uint256 _value;
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }
}

// OpenZeppelin Strings
library Strings {
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

// OpenSea Proxy Contracts
contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

// Main BoredApe Contract
contract BoredApe is ERC721, Ownable, ReentrancyGuard, PaymentSplitter {
    using Strings for uint256;
    using Counters for Counters.Counter;

    bytes32 public root;
    address public proxyRegistryAddress;
    uint256 public maxSupply = 100;
    string public baseURI;
    string public notRevealedUri = "ipfs://QmYUuwLoiRb8woXwJCCsr1gvbr8E21KuxRtmVBmnH1tZz7/hidden.json";
    string public baseExtension = ".json";
    bool public paused = false;
    bool public revealed = false;
    bool public presaleM = false;
    bool public publicM = false;
    uint256 public presaleAmountLimit = 3;
    mapping(address => uint256) public _presaleClaimed;
    uint256 public _price = 10000000000000000; // 0.01 ETH
    Counters.Counter private _tokenIds;

    uint256[] private _teamShares = [25, 35, 40];
    address[] private _team = [
        0x933572D5F83B00A998102b7bf1a99c0f197E685B, // Admin Account gets 25%
        0x82de9CE4a49fFeC4C41Cf733126F618eD83a879C, // Test Account gets 35%
        0x8a7aC9834e2D4487Da22Dc130C97Ee8fBDc85568  // VIP Account gets 40%
    ];

    constructor(string memory uri, bytes32 merkleroot, address _proxyRegistryAddress)
        ERC721("BoredApe", "APE")
        PaymentSplitter(_team, _teamShares)
        ReentrancyGuard()
    {
        root = merkleroot;
        proxyRegistryAddress = _proxyRegistryAddress;
        setBaseURI(uri);
    }

    function setBaseURI(string memory _tokenBaseURI) public onlyOwner {
        baseURI = _tokenBaseURI;
    }

    function _baseURI() internal view returns (string memory) {
        return baseURI;
    }

    function reveal() public onlyOwner {
        revealed = true;
    }

    function setMerkleRoot(bytes32 merkleroot) public onlyOwner {
        root = merkleroot;
    }

    modifier onlyAccounts() {
        require(msg.sender == tx.origin, "Not allowed origin");
        _;
    }

    modifier isValidMerkleProof(bytes32[] calldata _proof) {
        require(
            MerkleProof.verify(
                _proof,
                root,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "Not allowed origin"
        );
        _;
    }

    function togglePause() public onlyOwner {
        paused = !paused;
    }

    function togglePresale() public onlyOwner {
        presaleM = !presaleM;
    }

    function togglePublicSale() public onlyOwner {
        publicM = !publicM;
    }

    function presaleMint(address account, uint256 _amount, bytes32[] calldata _proof)
        external
        payable
        isValidMerkleProof(_proof)
        onlyAccounts
    {
        require(msg.sender == account, "CryptoPunks: Not allowed");
        require(presaleM, "CryptoPunks: Presale is OFF");
        require(!paused, "CryptoPunks: Contract is paused");
        require(_amount > 0, "CryptoPunks: Zero amount");
        require(_amount <= presaleAmountLimit, "CryptoPunks: Exceeds presale limit");
        require(_presaleClaimed[msg.sender] + _amount <= presaleAmountLimit, "CryptoPunks: Exceeds presale limit");
        require(_price * _amount <= msg.value, "CryptoPunks: Not enough ethers sent");

        uint256 current = _tokenIds.current();
        require(current + _amount <= maxSupply, "CryptoPunks: Max supply exceeded");

        _presaleClaimed[msg.sender] += _amount;
        for (uint256 i = 0; i < _amount; i++) {
            mintInternal();
        }
    }

    function publicSaleMint(uint256 _amount)
        external
        payable
        onlyAccounts
    {
        require(publicM, "CryptoPunks: PublicSale is OFF");
        require(!paused, "CryptoPunks: Contract is paused");
        require(_amount > 0, "CryptoPunks: Zero amount");
        require(_price * _amount <= msg.value, "CryptoPunks: Not enough ethers sent");

        uint256 current = _tokenIds.current();
        require(current + _amount <= maxSupply, "CryptoPunks: Max supply exceeded");

        for (uint256 i = 0; i < _amount; i++) {
            mintInternal();
        }
    }

    function mintInternal() internal nonReentrant {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _safeMint(msg.sender, tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");
        if (!revealed) {
            return notRevealedUri;
        }

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
                : "";
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }
        return super.isApprovedForAll(owner, operator);
    }
}