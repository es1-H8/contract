pragma solidity ^0.5.0;

// Standard ERC20 Token Contract
contract TestToken {
    string public name = "Test Token";
    string public symbol = "TST";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() public {
        totalSupply = 1000000 * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
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
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Insufficient allowance");
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

    //declaring owner state variable
    address public owner;

    //declaring default APY (default 0.1% daily or 36.5% APY yearly)
    uint256 public defaultAPY = 100;

    //declaring APY for custom staking ( default 0.137% daily or 50% APY yearly)
    uint256 public customAPY = 137;

    //declaring total staked
    uint256 public totalStaked;
    uint256 public customTotalStaked;

    //users staking balance
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public customStakingBalance;

    //mapping list of users who ever staked
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public customHasStaked;

    //mapping list of users who are staking at the moment
    mapping(address => bool) public isStakingAtm;
    mapping(address => bool) public customIsStakingAtm;

    //array of all stakers
    address[] public stakers;
    address[] public customStakers;

    constructor() public payable {
        testToken = new TestToken();
        owner = msg.sender;
    }

    //stake tokens function
    function stakeTokens(uint256 _amount) public {
        require(_amount > 0, "amount cannot be 0");
        testToken.transferFrom(msg.sender, address(this), _amount);
        totalStaked = totalStaked + _amount;
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }
        hasStaked[msg.sender] = true;
        isStakingAtm[msg.sender] = true;
    }

    //unstake tokens function
    function unstakeTokens() public {
        uint256 balance = stakingBalance[msg.sender];
        require(balance > 0, "amount has to be more than 0");
        testToken.transfer(msg.sender, balance);
        totalStaked = totalStaked - balance;
        stakingBalance[msg.sender] = 0;
        isStakingAtm[msg.sender] = false;
    }

    // different APY Pool
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

    //airdropp tokens
    function redistributeRewards() public {
        require(msg.sender == owner, "Only contract creator can redistribute");
        for (uint256 i = 0; i < stakers.length; i++) {
            address recipient = stakers[i];
            uint256 balance = stakingBalance[recipient] * defaultAPY;
            balance = balance / 100000;
            if (balance > 0) {
                testToken.transfer(recipient, balance);
            }
        }
    }

    //customAPY airdrop
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

    //change APY value for custom staking
    function changeAPY(uint256 _value) public {
        require(msg.sender == owner, "Only contract creator can change APY");
        require(_value > 0, "APY value has to be more than 0, try 100 for (0.100% daily) instead");
        customAPY = _value;
    }

    //claim test 1000 Tst (for testing purpose only !!)
    function claimTst() public {
        address recipient = msg.sender;
        uint256 tst = 1000000000000000000000;
        testToken.transfer(recipient, tst);
    }
}