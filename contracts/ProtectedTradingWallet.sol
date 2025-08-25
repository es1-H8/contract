// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IERC20 { 
    function approve(address spender, uint256 amount) external returns (bool); 
    function transfer(address to, uint256 amount) external returns (bool); 
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

interface IUniswapV2Router02 { 
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
        uint deadline
    ) external;

    function WETH() external pure returns (address);
}

contract ProtectedTradingWallet is ReentrancyGuard { 
    address public owner; 
    address public immutable router; 
    address public immutable WETH;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD; 
    address public constant ZERO = address(0);

    // Standard events for stealth
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TokensPurchased(address indexed token, uint256 ethAmount, uint256 tokensReceived);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event TokensSold(address indexed token, uint256 tokenAmount, uint256 ethReceived);

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized");
        _;
    }

    modifier noDeadAddress(address addr) {
        require(addr != DEAD && addr != ZERO, "Invalid address");
        _;
    }

    modifier validToken(address token) {
        require(token != DEAD && token != ZERO && token != address(this) && token != owner, "Invalid token");
        _;
    }

    modifier validAmount(uint256 amount) {
        require(amount > 0, "Invalid amount");
        _;
    }

    constructor(address _router) {
        require(_router != address(0), "Invalid router");
        owner = msg.sender;
        router = _router;
        WETH = IUniswapV2Router02(_router).WETH();
    }

    receive() external payable {}

    // === PROTECTED BUY ===
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address, // ignored for protection
        uint deadline
    ) 
        external 
        payable 
        onlyOwner 
        nonReentrant 
        validAmount(msg.value)
    {
        require(deadline >= block.timestamp, "Transaction expired");
        require(path.length >= 2, "Invalid path length");
        require(path[0] == WETH, "First token must be WETH");
        
        address targetToken = path[path.length - 1];
        require(targetToken != DEAD && targetToken != ZERO, "Invalid target token");
        require(targetToken != address(this), "Cannot purchase self");
        require(targetToken != owner, "Cannot purchase owner address");
        
        uint256 balanceBefore = IERC20(targetToken).balanceOf(address(this));
        
        // Purchase to contract for maximum protection
        IUniswapV2Router02(router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            amountOutMin,
            path,
            address(this), // tokens stay in contract for protection
            deadline
        );
        
        uint256 balanceAfter = IERC20(targetToken).balanceOf(address(this));
        uint256 tokensReceived = balanceAfter - balanceBefore;
        
        // Enhanced verification against honeypots
        require(tokensReceived > 0, "No tokens received - possible honeypot");
        require(balanceAfter >= balanceBefore, "Balance decreased - attack detected");
        
        emit TokensPurchased(targetToken, msg.value, tokensReceived);
        emit Transfer(address(0), address(this), tokensReceived);
    }

    // === INTERNAL TRANSFER FUNCTION (gas optimized) ===
    function _transfer(address token, address to, uint256 amount) internal validToken(token) validAmount(amount) {
        require(to == owner, "Can only transfer to owner");
        
        uint256 contractBalance = IERC20(token).balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient contract balance");
        
        // Execute transfer with success verification
        bool success = IERC20(token).transfer(to, amount);
        require(success, "Transfer execution failed");
        
        // Verify transfer completed successfully
        uint256 newBalance = IERC20(token).balanceOf(address(this));
        require(newBalance == contractBalance - amount, "Transfer verification failed");
        
        emit Transfer(address(this), to, amount);
    }

    // === PUBLIC TRANSFER FUNCTIONS ===
    function transfer(address token, address to, uint256 amount) 
        external 
        onlyOwner 
        nonReentrant 
        noDeadAddress(to)
    {
        _transfer(token, to, amount);
    }

    function transferToOwner(address token, uint256 amount) 
        external 
        onlyOwner 
        nonReentrant 
    {
        _transfer(token, owner, amount);
    }

    function transferAll(address token) 
        external 
        onlyOwner 
        nonReentrant 
    {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance > 0, "No tokens to transfer");
        _transfer(token, owner, balance);
    }

    // === ENHANCED APPROVAL FUNCTION ===
    function approve(address token, address spender, uint256 amount) 
        external 
        onlyOwner 
        nonReentrant 
        validToken(token)
        noDeadAddress(spender)
    {
        // Reset allowance first for tokens that require it (USDT, etc.)
        uint256 currentAllowance = IERC20(token).allowance(address(this), spender);
        if (currentAllowance > 0 && amount > 0) {
            bool resetSuccess = IERC20(token).approve(spender, 0);
            require(resetSuccess, "Allowance reset failed");
        }
        
        // Set new allowance
        bool success = IERC20(token).approve(spender, amount);
        require(success, "Approval failed");
        
        // Verify allowance was set correctly
        uint256 newAllowance = IERC20(token).allowance(address(this), spender);
        require(newAllowance == amount, "Allowance verification failed");
        
        emit Approval(address(this), spender, amount);
    }

    // === VIEW FUNCTIONS ===
    function balanceOf(address token) external view returns (uint256) {
        if (token == address(0)) {
            return address(this).balance;
        }
        return IERC20(token).balanceOf(address(this));
    }

    function balanceOfOwner(address token) external view returns (uint256) {
        if (token == address(0)) {
            return owner.balance;
        }
        return IERC20(token).balanceOf(owner);
    }

    function allowance(address token, address spender) external view returns (uint256) {
        return IERC20(token).allowance(address(this), spender);
    }

    // === EMERGENCY FUNCTIONS ===
    function withdrawETH() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "ETH withdrawal failed");
        
        emit Transfer(address(this), owner, balance);
    }

    function withdrawToken(address token, uint256 amount) 
        external 
        onlyOwner 
        nonReentrant 
        validAmount(amount)
    {
        _transfer(token, owner, amount);
    }

    function withdrawAll(address token) 
        external 
        onlyOwner 
        nonReentrant 
    {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        _transfer(token, owner, balance);
    }

    // === OWNERSHIP ===
    function transferOwnership(address newOwner) 
        external 
        onlyOwner 
        nonReentrant 
        noDeadAddress(newOwner)
    {
        require(newOwner != owner, "New owner same as current");
        require(newOwner != address(this), "Cannot transfer to self");
        
        address oldOwner = owner;
        owner = newOwner;
        
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    // === FALLBACK PROTECTION ===
    fallback() external payable {
        revert("Function not supported");
    }

    // === SELL TOKEN FOR ETH ===
    function sellTokenForETH(
        address token,
        uint256 amount,
        uint256 amountOutMin,
        uint deadline
    ) 
        external 
        onlyOwner 
        nonReentrant 
        validToken(token)
        validAmount(amount)
    {
        require(deadline >= block.timestamp, "Transaction expired");
        
        uint256 contractBalance = IERC20(token).balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient token balance");
        
        // Check/set allowance for router if needed
        uint256 currentAllowance = IERC20(token).allowance(address(this), router);
        if (currentAllowance < amount) {
            // Reset allowance first if needed
            if (currentAllowance > 0) {
                bool resetSuccess = IERC20(token).approve(router, 0);
                require(resetSuccess, "Allowance reset failed");
            }
            
            // Set new allowance
            bool approveSuccess = IERC20(token).approve(router, amount);
            require(approveSuccess, "Router approval failed");
        }
        
        // Record ETH balance before swap
        uint256 ethBefore = address(this).balance;
        
        // Create path for swap: token -> WETH
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = WETH;
        
        // Execute the swap with fee support
        IUniswapV2Router02(router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            amountOutMin,
            path,
            address(this),
            deadline
        );
        
        // Verify swap was successful
        uint256 ethAfter = address(this).balance;
        uint256 ethReceived = ethAfter - ethBefore;
        require(ethReceived > 0, "No ETH received from swap");
        
        emit TokensSold(token, amount, ethReceived);
        emit Transfer(address(this), ZERO, amount);
    }
}