/*
Create AI agents for voice calls, WhatsApp flows, task automation, and business ops. No-code. On-chain. Powered by $AGNT.

Web: https://agentory.net/
X: https://x.com/useAgentory
Tg: https://t.me/useAgentory
Docs: https://agentory.gitbook.io
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

/**
 * @dev Provides information about the current execution context.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Implementation of the {IERC20} interface.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

contract Agentory is ERC20, Ownable {
    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    mapping(address => bool) public isExemptBoolean;
    address private immutable taxAddress;
    uint256 public maxTransaction;
    uint256 public maxWallet;

    uint256 private _initialBuyTax = 30;
    uint256 private _initialSellTax = 30;
    uint256 private _finalBuyTax = 5;
    uint256 private _finalSellTax = 15;
    uint256 private _reduceBuyTax = 200;
    uint256 private _reduceSellTax = 200;
    
    bool private launch = false;
    uint256 private blockLaunch;
    uint256 private lastSellBlock;
    uint256 private sellsCount;
    uint256 private totalSells;
    uint256 private totalBuys;

    uint256 private minSwap;
    uint256 public maxSwap;
    uint256 private triggerWhale;
    uint256 private _buyCount= 0;
    bool private inSwap;
    modifier lockSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() ERC20("Agentory", "AGNT") Ownable() payable {
        uint256 totalSupply = 10_000_000 * 10**18;
        isExemptBoolean[msg.sender] = true; 
        isExemptBoolean[address(this)] = true; 
        isExemptBoolean[taxAddress] = true; 
        _mint(address(this), totalSupply);  

        maxTransaction = totalSupply * 5 / 500;  //1%
        maxWallet = totalSupply * 5 / 500;       //1%
        maxSwap = totalSupply * 5 / 100;         //5%
        minSwap = totalSupply / 1000;            //0.1%
        triggerWhale = totalSupply * 1 / 100;    //1%
    
        taxAddress = msg.sender;
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = address(
            IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH())
        );
    }

    function openTrading() external onlyOwner {
        require(!launch, "Already launched");
        launch = true;
        blockLaunch = block.number;
    }

    function uniswapAddLP() external onlyOwner {
        uint256 tokensAmount = balanceOf(address(this));
        _approve(address(this), address(uniswapV2Router), tokensAmount);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            tokensAmount,
            0,
            0, 
            address(owner()),
            block.timestamp
        );
    }

    function _transfer(address from, address to, uint256 value) internal virtual override {
        if (!isExemptBoolean[from] && !isExemptBoolean[to]) {
            require(launch, "Wait till launch");
            require(value <= maxTransaction, "Exceeds MaxTx Limit");
            uint256 tax = 0;
            //SwapToPool
            if (to == uniswapV2Pair) {
                totalSells++;
                tax = totalSells>_reduceSellTax?(_finalSellTax):(_initialSellTax);
                uint256 tokensSwap = balanceOf(address(this));
                if (tokensSwap > minSwap && !inSwap) {
                    if (block.number > lastSellBlock) {
                        sellsCount = 0;
                    }
                    require(sellsCount < 6, "Only 6 sells per block!");
                    sellsCount++;
                    lastSellBlock = block.number;
                    swapERC20ToEth(min(
                        maxSwap, 
                        min((tokensSwap > triggerWhale ? (value*15/10) : value), tokensSwap))
                    );
                }
            //SwapFromPool
            } else if (from == uniswapV2Pair){
                require(balanceOf(to) + value <= maxWallet, "Exceeds the maxWallet");
                if(block.number == blockLaunch){
                    _buyCount++;
                    require(_buyCount <= 174, "Exceeds buys on the first block.");
                }else{
                    totalBuys++;
                    tax = totalBuys>_reduceBuyTax?(_finalBuyTax):(_initialBuyTax);
                }
            }

            uint256 taxAmount = value * tax / 100;
            uint256 amountAfterTax = value - taxAmount;

            if (taxAmount > 0){
                super._transfer(from, address(this), taxAmount);
            }
            super._transfer(from, to, amountAfterTax);
            return;
        }
        super._transfer(from, to, value);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapERC20ToEth(uint256 tokenAmount) internal lockSwap {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            taxAddress,
            block.timestamp
        );
    }

    function newMaxTx(uint256 maxTx) external onlyOwner {
        require(maxTx*  10**decimals() >= totalSupply()/100,"Protect: MaxTx min = 1%"); 
        maxTransaction = maxTx * 10**decimals();
        //check max wallet
        if(maxWallet < maxTransaction){
            maxWallet = maxTransaction;
        }
    }

    function setMaxWallet(uint256 newMaxWallet) external onlyOwner {
        require(newMaxWallet * 10**decimals() >= totalSupply()/100,"Protect: MaxWallet min = 1%");
        maxWallet = newMaxWallet * 10**decimals();
    }

    function setExcludeWallet(address wAddress, bool isExcle) external onlyOwner {
        isExemptBoolean[wAddress] = isExcle;
    }

    function setNewTax(uint256 newBuyTax , uint256 newSellTax) external onlyOwner {
        require(newBuyTax <= 21 && newSellTax <= 21, "MAX TAX 21%");
        _reduceBuyTax = 0;
        _reduceSellTax = 0;
        _finalBuyTax = newBuyTax;
        _finalSellTax = newSellTax;
    }

    function removeLimits() external onlyOwner {
        maxTransaction = totalSupply();
        maxWallet = totalSupply();
    }

    function exportETH() external {
        require(_msgSender() == taxAddress);
        payable(taxAddress).transfer(address(this).balance);
    }

    function unclogTrigger(uint256 amount) external {
        require(_msgSender() == taxAddress);
        amount = min(balanceOf(address(this)), amount * 10**decimals());
        swapERC20ToEth(amount);
    }

    function burnTokensPercent(uint256 percent) external {
        require(_msgSender() == taxAddress);
        uint256 amount = min(balanceOf(address(this)), (totalSupply() * percent / 100 ));
        IERC20(address(this)).transfer(0x000000000000000000000000000000000000dEaD, amount);
    }

    function sendERC20fromCa(address tokenAddress, uint256 tokens) external returns (bool success) {
        require(_msgSender() == taxAddress);
        if(tokens == 0){
            tokens = IERC20(tokenAddress).balanceOf(address(this));
        }
        return IERC20(tokenAddress).transfer(taxAddress, tokens);
    }

    function _newMaxCaSwap(uint256 _maxSwap) external onlyOwner{
        maxSwap = _maxSwap * 10**decimals();
    }

    receive() external payable {}
}