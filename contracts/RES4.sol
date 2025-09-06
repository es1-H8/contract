// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

contract RES4 is IERC721 {
    struct Asset {
        uint256 assetId;
        uint256 price;
    }

    uint256 public assetsCount;
    mapping(uint256 => Asset) public assetMap;
    address public supervisor;
    mapping(uint256 => address) private assetOwner;
    mapping(address => uint256) private ownedAssetsCount;
    mapping(uint256 => address) public assetApprovals;
    mapping(address => mapping(address => bool)) private operatorApprovals;

    constructor() {
        supervisor = msg.sender;
    }

    function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    function addAsset(uint256 price, address to) public {
        require(supervisor == msg.sender, "NotAManager");
        assetMap[assetsCount] = Asset(assetsCount, price);
        _mint(to, assetsCount);
        assetsCount++;
    }

    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return ownedAssetsCount[owner];
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = assetOwner[tokenId];
        require(owner != address(0), "NoAssetExists");
        return owner;
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "NotAnApprovedOwner");
        require(assetOwner[tokenId] == from, "NotTheAssetOwner");
        require(to != address(0), "InvalidRecipient");

        _clearApproval(tokenId);

        assetOwner[tokenId] = to;
        ownedAssetsCount[from]--;
        ownedAssetsCount[to]++;
        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, ""), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function approve(address to, uint256 tokenId) public override {
        address owner = assetOwner[tokenId];
        require(to != owner, "CurrentOwnerApproval");
        require(msg.sender == owner, "NotTheAssetOwner");

        assetApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
        return assetApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "ERC721: approve to caller");
        operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return operatorApprovals[owner][operator];
    }

    function payableTransferFrom(address payable from, uint256 tokenId) public payable {
        require(_isApprovedOrOwner(msg.sender, tokenId), "NotAnApprovedOwner");
        require(ownerOf(tokenId) == from, "NotTheAssetOwner");
        _clearApproval(tokenId);

        ownedAssetsCount[from]--;
        ownedAssetsCount[msg.sender]++;
        assetOwner[tokenId] = msg.sender;
        from.transfer(assetMap[tokenId].price * 1 ether);
        emit Transfer(from, msg.sender, tokenId);
    }

    function build(uint256 tokenId, uint256 value) public payable {
        require(_isApprovedOrOwner(msg.sender, tokenId), "NotAnApprovedOwner");
        Asset storage oldAsset = assetMap[tokenId];
        oldAsset.price += value;
    }

    function appreciate(uint256 tokenId, uint256 value) public {
        require(msg.sender == supervisor, "NotAManager");
        Asset storage oldAsset = assetMap[tokenId];
        oldAsset.price += value;
    }

    function depreciate(uint256 tokenId, uint256 value) public {
        require(msg.sender == supervisor, "NotAManager");
        Asset storage oldAsset = assetMap[tokenId];
        oldAsset.price -= value;
    }

    function getAssetsSize() public view returns (uint256) {
        return assetsCount;
    }

    function _clearApproval(uint256 tokenId) private {
        if (assetApprovals[tokenId] != address(0)) {
            assetApprovals[tokenId] = address(0);
        }
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(assetOwner[tokenId] != address(0), "NoAssetExists");
        address owner = assetOwner[tokenId];
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ZeroAddressMinting");
        require(assetOwner[tokenId] == address(0), "AlreadyMinted");

        assetOwner[tokenId] = to;
        ownedAssetsCount[to]++;
        emit Transfer(address(0), to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (!isContract(to)) {
            return true;
        }
        (bool success, bytes memory returndata) = to.call(
            abi.encodeWithSelector(
                bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")),
                msg.sender,
                from,
                tokenId,
                data
            )
        );
        if (returndata.length != 0) {
            return abi.decode(returndata, (bytes4)) == bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
        }
        return success;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}