// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MemeToken is ERC20 {
    address payable public owner;
    address public creator;

    constructor(address _creator, string memory _name, string memory _symbol, uint256 _totalSupply) ERC20(_name, _symbol) {
        owner = payable(msg.sender);
        creator = _creator;
        _mint(msg.sender, _totalSupply);
    }
}

error MemeFactory__InsufficientFee();
error MemeFactory__InsufficientETH();
error MemeFactory__SaleClosed();
error MemeFactory__TokenAmountTooLow();
error MemeFactory__AmountExceeded();
error MemeFactory__TransferFailed();
error MemeFactory__NotOwner();

contract MemeFactory {
    uint256 public constant TOKEN_LIMIT = 500_000 ether;
    uint256 public constant TARGET = 3 ether;

    uint256 public immutable fee;
    address public owner;
    uint256 public totalTokens;

    struct TokenSale {
        address token;
        string name;
        string symbol;
        address creator;
        uint256 sold;
        uint256 raised;
        bool isOpen;
    }

    mapping(address => TokenSale) public tokenToSale;
    address[] public tokens;

    event Created(address indexed token);
    event BoughtToken(address indexed token, uint256 amount);

    constructor(uint256 _fee) {
        fee = _fee;
        owner = msg.sender;
    }

    function create(string memory _name, string memory _symbol) public payable {
        if (msg.value < fee) revert MemeFactory__InsufficientFee();

        MemeToken token = new MemeToken(msg.sender, _name, _symbol, 1_000_000 ether);
        tokens.push(address(token));
        totalTokens += 1;

        TokenSale memory sale = TokenSale(address(token), _name, _symbol, msg.sender, 0, 0, true);
        tokenToSale[address(token)] = sale;

        emit Created(address(token));
    }

    function buyToken(address _token, uint256 _amount) external payable {
        TokenSale storage sale = tokenToSale[_token];

        if (sale.isOpen == false) revert MemeFactory__SaleClosed();
        if (_amount < 0.001 ether) revert MemeFactory__TokenAmountTooLow();
        if (_amount >= 1000 ether) revert MemeFactory__AmountExceeded();

        uint256 cost = getCost(sale.sold);
        uint256 price = cost * (_amount / 10 ** 18);

        if (msg.value < price) revert MemeFactory__InsufficientETH();

        sale.sold += _amount;
        sale.raised += price;

        if (sale.sold >= TOKEN_LIMIT || sale.raised >= TARGET) sale.isOpen = false;

        MemeToken(_token).transfer(msg.sender, _amount);

        emit BoughtToken(_token, _amount);
    }

    function deposit(address _token) external {
        TokenSale memory sale = tokenToSale[_token];

        MemeToken token = MemeToken(_token);
        token.transfer(sale.creator, token.balanceOf(address(this)));

        (bool success, ) = payable(sale.creator).call{value: sale.raised}("");
        if (!success) revert MemeFactory__TransferFailed();
    }

    function withdraw(uint256 _amount) external {
        if (msg.sender != owner) revert MemeFactory__NotOwner();

        (bool success, ) = payable(owner).call{value: _amount}("");
        if (!success) revert MemeFactory__TransferFailed();
    }

    function getCost(uint256 _sold) public pure returns (uint256) {
        uint256 floor = 0.0001 ether;
        uint256 step = 0.0001 ether;
        uint256 increment = 10000 ether;

        uint256 cost = (step * (_sold / increment)) + floor;
        return cost;
    }

    function getTokenSale(uint256 _index) public view returns (TokenSale memory) {
        return tokenToSale[tokens[_index]];
    }
}