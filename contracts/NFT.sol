pragma solidity 0.5.0;

// Use these imports for local npm installation (openzeppelin-solidity@2.3.0)
import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721Metadata.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721Enumerable.sol";

contract nftContract is ERC721, ERC721Metadata, ERC721Enumerable {
    struct nftData {
        uint256 clothType; // 1 --> head, 2 --> middle, 3 --> bottom
        string name;
        string cid;
        string rarity;
        bool isOnSale;
        uint256 sellPrice;
        bool isBiddable;
        uint256 maxBid;
        address maxBidder;
        bool isWearing;
    }

    struct userData {
        uint256 head; 
        uint256 middle;
        uint256 bottom;
        string username;
        uint256 userBalance;
    }

    event nftTransaction(
        uint256 indexed id,
        string transactionType,
        address fromAddress,
        address toAddress,
        uint256 value
    );
    
    mapping(address => userData) public users;
    mapping(string => bool) isExist;
    nftData[] public nfts;

    address public owner;
    uint256 public maxSupply;
    
    constructor() public ERC721Metadata("nftContract", "NFTC") {
        owner = msg.sender;
        maxSupply = 100;
    }

    function setUsername(string memory _username) public {
        users[msg.sender].username = _username;
    }

    function wearItems(
        uint256 _headTokenId,
        uint256 _middleTokenId,
        uint256 _bottomTokenId
    ) public {
        require(
            _headTokenId == 0 ||
                (ownerOf(_headTokenId) == msg.sender &&
                    nfts[_headTokenId - 1].clothType == 1),
            "You must be the owner or you tried a non-head item for head"
        );
        require(
            _middleTokenId == 0 ||
                (ownerOf(_middleTokenId) == msg.sender &&
                    nfts[_middleTokenId - 1].clothType == 2),
            "You must be the owner or you tried a non-middle item for middle"
        );
        require(
            _bottomTokenId == 0 ||
                (ownerOf(_bottomTokenId) == msg.sender &&
                    nfts[_bottomTokenId - 1].clothType == 3),
            "You must be the owner or you tried a non-bottom item for bottom"
        );
        
        require(_headTokenId == 0 || nfts[_headTokenId - 1].isOnSale == false, "Head item is on sale, you cannot wear it");
        require(_headTokenId == 0 || nfts[_headTokenId - 1].isBiddable == false, "Head item is on bid, you cannot wear it");
        require(_middleTokenId == 0 || nfts[_middleTokenId - 1].isOnSale == false, "Middle item is on sale, you cannot wear it");
        require(_middleTokenId == 0 || nfts[_middleTokenId - 1].isBiddable == false, "Middle item is on bid, you cannot wear it");
        require(_bottomTokenId == 0 || nfts[_bottomTokenId - 1].isOnSale == false, "Bottom item is on sale, you cannot wear it");
        require(_bottomTokenId == 0 || nfts[_bottomTokenId - 1].isBiddable == false, "Bottom item is on bid, you cannot wear it");

        if (users[msg.sender].head != 0) {
            nfts[users[msg.sender].head - 1].isWearing = false;
        }
        if (users[msg.sender].middle != 0) {
            nfts[users[msg.sender].middle - 1].isWearing = false;
        }
        if (users[msg.sender].bottom != 0) {
            nfts[users[msg.sender].bottom - 1].isWearing = false;
        }

        if (_headTokenId != 0) {
            nfts[_headTokenId - 1].isWearing = true;
        }
        if (_middleTokenId != 0) {
            nfts[_middleTokenId - 1].isWearing = true;
        }
        if (_bottomTokenId != 0) {
            nfts[_bottomTokenId - 1].isWearing = true;
        }

        users[msg.sender].head = _headTokenId;
        users[msg.sender].middle = _middleTokenId;
        users[msg.sender].bottom = _bottomTokenId;
    }

    function wearItem(uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "You are not the owner of this item, so you cannot wear it");
        require(nfts[_tokenId - 1].isOnSale == false, "You cannot wear an item while it is on sale");
        require(nfts[_tokenId - 1].isBiddable == false, "You cannot wear an item while it is on auction");

        if (nfts[_tokenId - 1].clothType == 1) {
            if (users[msg.sender].head != 0) {
                nfts[users[msg.sender].head - 1].isWearing = false;
            }
            users[msg.sender].head = _tokenId;
        } else if (nfts[_tokenId - 1].clothType == 2) {
            if (users[msg.sender].middle != 0) {
                nfts[users[msg.sender].middle - 1].isWearing = false;
            }
            users[msg.sender].middle = _tokenId;
        } else if (nfts[_tokenId - 1].clothType == 3) {
            if (users[msg.sender].bottom != 0) {
                nfts[users[msg.sender].bottom - 1].isWearing = false;
            }
            users[msg.sender].bottom = _tokenId;
        }
        nfts[_tokenId - 1].isWearing = true;
    }

    function unWearItem(uint256 _clothType) public {
        require(_clothType == 1 || _clothType == 2 || _clothType == 3, "Invalid cloth type");

        if (_clothType == 1) {
            require(users[msg.sender].head != 0, "You must wear a head item first to unwear");
            nfts[users[msg.sender].head - 1].isWearing = false;
            users[msg.sender].head = 0;
        } else if (_clothType == 2) {
            require(users[msg.sender].middle != 0, "You must wear a middle item first to unwear");
            nfts[users[msg.sender].middle - 1].isWearing = false;
            users[msg.sender].middle = 0;
        } else if (_clothType == 3) {
            require(users[msg.sender].bottom != 0, "You must wear a bottom item first to unwear");
            nfts[users[msg.sender].bottom - 1].isWearing = false;
            users[msg.sender].bottom = 0;
        }
    }

    function tokensOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        return _tokensOfOwner(_owner);
    }

    function putOnSale(uint256 _tokenId, uint256 _sellPrice) public {
        require(ownerOf(_tokenId) == msg.sender, "You cannot put this item on sale, because you are not the owner");
        require(nfts[_tokenId - 1].isOnSale == false, "Item is already on sale");
        require(nfts[_tokenId - 1].isWearing == false, "You must unwear it first, then you can sell it");
        
        nfts[_tokenId - 1].isOnSale = true;
        nfts[_tokenId - 1].sellPrice = _sellPrice; 
        approve(address(this), _tokenId);

        emit nftTransaction(
            _tokenId,
            "On Sale",
            msg.sender,
            address(0),
            _sellPrice
        ); 
    }

    function cancelSale(uint256 _tokenId) public {
        require(nfts[_tokenId - 1].isOnSale == true, "Item should be on sale first to be cancelled");
        require(ownerOf(_tokenId) == msg.sender, "You cannot cancel the sale of this item, because you are not the owner");
        
        nfts[_tokenId - 1].isOnSale = false; 
        nfts[_tokenId - 1].sellPrice = 0; 

        emit nftTransaction(
            _tokenId,
            "Sale Cancelled",
            msg.sender,
            address(0),
            0
        ); 
    }

    function buyFromSale(uint256 _tokenId) public payable {
        require(msg.sender != ownerOf(_tokenId), "You cannot buy your own item");
        require(nfts[_tokenId - 1].isOnSale == true, "Item should be on sale for you to buy it");
        require(nfts[_tokenId - 1].sellPrice <= msg.value, "The amount you sent is less than the price");
        require(getApproved(_tokenId) == address(this), "Seller did not give allowance for us to sell this item, contact the seller");
        
        address sellerAddress = ownerOf(_tokenId);
        safeTransferFrom(sellerAddress, msg.sender, _tokenId);
        nfts[_tokenId - 1].isOnSale = false; 
        nfts[_tokenId - 1].sellPrice = 0; 
        users[sellerAddress].userBalance = add256(users[sellerAddress].userBalance, msg.value); 

        if (nfts[_tokenId - 1].maxBid > 0) {
            users[nfts[_tokenId - 1].maxBidder].userBalance = add256(users[nfts[_tokenId - 1].maxBidder].userBalance, nfts[_tokenId - 1].maxBid); 
        }
        nfts[_tokenId - 1].maxBid = 0;
        nfts[_tokenId - 1].maxBidder = address(0);
        nfts[_tokenId - 1].isBiddable = false; 

        emit nftTransaction(
            _tokenId,
            "Sold",
            sellerAddress,
            msg.sender,
            msg.value
        );
    }

    function putOnAuction(uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "Only owner of this item can put it on auction");
        require(nfts[_tokenId - 1].isWearing == false, "You must unwear it first, then you can put it on auction");
        require(nfts[_tokenId - 1].isBiddable == false, "This item is already on auction");
        
        nfts[_tokenId - 1].isBiddable = true; 
        nfts[_tokenId - 1].maxBid = 0; 
        approve(address(this), _tokenId);

        emit nftTransaction(
            _tokenId,
            "Auction Starts",
            msg.sender,
            address(0),
            0
        ); 
    }

    function cancelAuction(uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "You cannot cancel the auction of this item, because you are not the owner");
        require(nfts[_tokenId - 1].isBiddable == true, "Item must be on auction before it can be canceled");
        
        if (nfts[_tokenId - 1].maxBid > 0) {
            users[nfts[_tokenId - 1].maxBidder].userBalance = add256(users[nfts[_tokenId - 1].maxBidder].userBalance, nfts[_tokenId - 1].maxBid);
        }
        nfts[_tokenId - 1].isBiddable = false; 
        nfts[_tokenId - 1].maxBid = 0; 
        nfts[_tokenId - 1].maxBidder = address(0); 

        emit nftTransaction(
            _tokenId,
            "Auction Cancelled",
            msg.sender,
            address(0),
            0
        ); 
    }

    function bid(uint256 _tokenId) public payable {
        require(msg.value > 0, "You did not send any money");
        require(nfts[_tokenId - 1].isBiddable == true, "Item is not biddable");
        require(msg.value >= nfts[_tokenId - 1].maxBid, "The amount you bid is less than the current max bid");
        require(msg.sender != ownerOf(_tokenId), "You cannot bid on your own item");
        
        if (nfts[_tokenId - 1].maxBid > 0) {
            users[nfts[_tokenId - 1].maxBidder].userBalance = add256(users[nfts[_tokenId - 1].maxBidder].userBalance, nfts[_tokenId - 1].maxBid); 
        }
        nfts[_tokenId - 1].maxBid = msg.value;
        nfts[_tokenId - 1].maxBidder = msg.sender;

        emit nftTransaction(
            _tokenId,
            "Bidded",
            msg.sender,
            ownerOf(_tokenId),
            msg.value
        ); 
    }

    function acceptHighestBid(uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "You need to be the owner to accept the highest bid");
        require(nfts[_tokenId - 1].isBiddable == true, "Item should be biddable to accept its highest bid");
        require(nfts[_tokenId - 1].maxBid > 0, "Max bid must be more than 0 to accept it");
        require(nfts[_tokenId - 1].maxBidder != msg.sender, "Max bidder cannot be the same as the seller");

        address buyer = nfts[_tokenId - 1].maxBidder;
        uint256 soldValue = nfts[_tokenId - 1].maxBid;
        safeTransferFrom(msg.sender, buyer, _tokenId); 
        users[msg.sender].userBalance = add256(users[msg.sender].userBalance, nfts[_tokenId - 1].maxBid); 
        nfts[_tokenId - 1].maxBid = 0; 
        nfts[_tokenId - 1].maxBidder = address(0); 
        nfts[_tokenId - 1].isBiddable = false; 
        nfts[_tokenId - 1].isOnSale = false; 
        nfts[_tokenId - 1].sellPrice = 0; 

        emit nftTransaction(
            _tokenId,
            "Sold From Auction",
            msg.sender,
            buyer,
            soldValue
        );
    }

    function withdrawBid(uint256 _tokenId) public {
        require(msg.sender == nfts[_tokenId - 1].maxBidder, "You must be the max bidder to withdraw your bid");
        uint256 withdrawnValue = nfts[_tokenId - 1].maxBid;
        users[nfts[_tokenId - 1].maxBidder].userBalance = add256(users[nfts[_tokenId - 1].maxBidder].userBalance, nfts[_tokenId - 1].maxBid);
        nfts[_tokenId - 1].maxBid = 0; 
        nfts[_tokenId - 1].maxBidder = address(0); 

        emit nftTransaction(
            _tokenId,
            "Bid Withdrawn",
            msg.sender,
            address(0),
            withdrawnValue
        ); 
    }

    function withdrawMoney(uint256 _amount) public {
        require(users[msg.sender].userBalance >= _amount, "You do not have enough balance to withdraw this amount");
        uint256 initialBalance = users[msg.sender].userBalance;
        users[msg.sender].userBalance = sub256(initialBalance, _amount);
        msg.sender.transfer(_amount);
    }

    function mint(
        uint256 _clothType,
        string memory _name,
        string memory _cid,
        string memory _rarity
    ) public {
        require(isExist[_cid] == false, "Item link should be unique to mint it");
        require(totalSupply() < maxSupply, "Cannot mint more items, maximum supply reached");
        require(msg.sender == owner, "Only the contract owner can mint");
        require(_clothType == 1 || _clothType == 2 || _clothType == 3, "Invalid cloth type");
        
        uint256 _id = nfts.push(
            nftData(
                _clothType,
                _name,
                _cid,
                _rarity,
                false,
                0,
                false,
                0,
                address(0),
                false
            )
        );
        _mint(msg.sender, _id);
        isExist[_cid] = true;

        emit nftTransaction(_id, "Claimed", address(0), msg.sender, 0);

        putOnSale(_id, 10000000000000000);
    }

    function add256(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Addition overflow");
        return c;
    }

    function sub256(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Subtraction underflow");
        return a - b;
    }
}