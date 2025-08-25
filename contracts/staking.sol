pragma solidity ^0.5.0;

// ERC20 Test Token
contract TestToken {
    string public name = "TestToken";
    string public symbol = "Tst";
    uint256 public totalSupply = 1000000000000000000000000; // 1 million tokens
    uint8 public decimals = 18;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}

contract TokenStaking {
    string public name = "Yield Farming / Token dApp";
    TestToken public testToken;

    // Declaring owner state variable
    address public owner;

    // Declaring default APY (default 0.1% daily or 36.5% APY yearly)
    uint256 public defaultAPY = 100;

    // Declaring APY for custom staking (default 0.137% daily or 50% APY yearly)
    uint256 public customAPY = 137;

    // Declaring total staked
    uint256 public totalStaked;
    uint256 public customTotalStaked;

    // Users staking balance
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public customStakingBalance;

    // Mapping list of users who ever staked
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public customHasStaked;

    // Mapping list of users who are staking at the moment
    mapping(address => bool) public isStakingAtm;
    mapping(address => bool) public customIsStakingAtm;

    // Array of all stakers
    address[] public stakers;
    address[] public customStakers;

    constructor(TestToken _testToken) public payable {
        testToken = _testToken;
        // Assigning owner on deployment
        owner = msg.sender;
    }

    // Stake tokens function
    function stakeTokens(uint256 _amount) public {
        // Must be more than 0
        require(_amount > 0, "amount cannot be 0");

        // User adding test tokens
        testToken.transferFrom(msg.sender, address(this), _amount);
        totalStaked = totalStaked + _amount;

        // Updating staking balance for user by mapping
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        // Checking if user staked before or not, if NOT staked adding to array of stakers
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        // Updating staking status
        hasStaked[msg.sender] = true;
        isStakingAtm[msg.sender] = true;
    }

    // Unstake tokens function
    function unstakeTokens() public {
        // Get staking balance for user
        uint256 balance = stakingBalance[msg.sender];

        // Amount should be more than 0
        require(balance > 0, "amount has to be more than 0");

        // Transfer staked tokens back to user
        testToken.transfer(msg.sender, balance);
        totalStaked = totalStaked - balance;

        // Resetting users staking balance
        stakingBalance[msg.sender] = 0;

        // Updating staking status
        isStakingAtm[msg.sender] = false;
    }

    // Different APY Pool
    function customStaking(uint256 _amount) public {
        require(_amount > 0, "amount cannot be 0");
        testToken.transferFrom(msg.sender, address(this), _amount);
        customTotalStaked = customTotalStaked + _amount;
        customStakingBalance[msg.sender] = customStakingBalance[msg.sender] + _amount;

        if (!customHasStaked[msg.sender]) {
            customStakers.push(msg.sender);
        }
        customHasStaked[msg.sender] = true;
        customIsStakingAtm[msg.sender] = true;
    }

    function customUnstake() public {
        uint256 balance = customStakingBalance[msg.sender];
        require(balance > 0, "amount has to be more than 0");
        testToken.transfer(msg.sender, balance);
        customTotalStaked = customTotalStaked - balance;
        customStakingBalance[msg.sender] = 0;
        customIsStakingAtm[msg.sender] = false;
    }

    // Airdrop tokens
    function redistributeRewards() public {
        // Only owner can issue airdrop
        require(msg.sender == owner, "Only contract creator can redistribute");

        // Doing drop for all addresses
        for (uint256 i = 0; i < stakers.length; i++) {
            address recipient = stakers[i];

            // Calculating daily APY for user
            uint256 balance = stakingBalance[recipient] * defaultAPY;
            balance = balance / 100000;

            if (balance > 0) {
                testToken.transfer(recipient, balance);
            }
        }
    }

    // Custom APY airdrop
    function customRewards() public {
        require(msg.sender == owner, "Only contract creator can redistribute");
        for (uint256 i = 0; i < customStakers.length; i++) {
            address recipient = customStakers[i];
            uint256 balance = customStakingBalance[recipient] * customAPY;
            balance = balance / 100000;

            if (balance > 0) {
                testToken.transfer(recipient, balance);
            }
        }
    }

    // Change APY value for custom staking
    function changeAPY(uint256 _value) public {
        // Only owner can issue airdrop
        require(msg.sender == owner, "Only contract creator can change APY");
        require(_value > 0, "APY value has to be more than 0, try 100 for (0.100% daily) instead");
        customAPY = _value;
    }

    // Claim test 1000 Tst (for testing purpose only !!)
    function claimTst() public {
        address recipient = msg.sender;
        uint256 tst = 1000000000000000000000;
        uint256 balance = tst;
        testToken.transfer(recipient, balance);
    }
}