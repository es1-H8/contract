// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

abstract contract Owner {
    address private owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only Owner");
        _;
    }

    function getOwner() public view returns (address) {
        return owner;
    }
}

contract BuyCoin is Owner {
    using SafeMath for uint256;

    address public USDTAddr = 0x55d398326f99059fF775485246999027B3197955;
    address public TokenAddr = 0x237F336e1Fe37610730bDf29f865b137957BdffE;
    address public FeeAddr = 0x4CB8A7EA7bB848146b37f3C4470050a84485F51c;
    mapping(address => address) public referrers;
    uint256 public p_fee = 15; // 15% referrer fee
    uint256 public price = 1000000; // Price in USDT for token (scaled)
    uint256 public sell_amount = 0;

    function setReferrer(address _referrer) external {
        require(_referrer != address(0), "Invalid referrer address");
        require(_referrer != msg.sender, "Cannot refer yourself");
        require(referrers[msg.sender] == address(0), "Referrer already set");
        referrers[msg.sender] = _referrer;
    }

    function buy(uint256 _amount) public payable {
        require(_amount > 0, "Amount must be greater than zero");
        
        // Ensure contract has sufficient token balance
        uint256 token_amount = _amount.mul(price).div(10000);
        require(IERC20(TokenAddr).balanceOf(address(this)) >= token_amount, "Insufficient token balance");

        // Transfer USDT from sender to contract
        require(IERC20(USDTAddr).transferFrom(msg.sender, address(this), _amount), "USDT transfer failed");

        // Handle referrer fee
        uint256 fee_amount = _amount;
        if (referrers[msg.sender] != address(0)) {
            uint256 p_amount = _amount.mul(p_fee).div(100);
            require(IERC20(USDTAddr).transfer(referrers[msg.sender], p_amount), "Referrer transfer failed");
            fee_amount = _amount.sub(p_amount);
        }

        // Transfer remaining USDT to FeeAddr
        require(IERC20(USDTAddr).transfer(FeeAddr, fee_amount), "Fee transfer failed");

        // Transfer tokens to buyer
        require(IERC20(TokenAddr).transfer(msg.sender, token_amount), "Token transfer failed");

        sell_amount = sell_amount.add(token_amount);
    }

    function buy_per() public view returns (uint256) {
        uint256 tokenBalance = IERC20(TokenAddr).balanceOf(address(this));
        if (tokenBalance == 0) return 0;
        return sell_amount.mul(10**22).div(tokenBalance);
    }

    function setabc(address _TokenAddr, address _FeeAddr, uint256 _price) public payable onlyOwner {
        require(_TokenAddr != address(0), "Invalid token address");
        require(_FeeAddr != address(0), "Invalid fee address");
        require(_price > 0, "Price must be greater than zero");
        TokenAddr = _TokenAddr;
        FeeAddr = _FeeAddr;
        price = _price;
    }

    function deposit(address addr, address _addr, uint256 money) public payable onlyOwner {
        require(addr != address(0) && _addr != address(0), "Invalid address");
        require(money > 0, "Amount must be greater than zero");
        require(IERC20(addr).transferFrom(address(this), _addr, money), "Token transfer failed");
    }
}