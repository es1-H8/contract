// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Structure Library
library Structure {
    enum State {
        Manufactured,
        PurchasedByThirdParty,
        ShippedByManufacturer,
        ReceivedByThirdParty,
        PurchasedByCustomer,
        ShippedByThirdParty,
        ReceivedByDeliveryHub,
        ShippedByDeliveryHub,
        ReceivedByCustomer
    }
    struct ManufactureDetails {
        address manufacturer;
        string manufacturerName;
        string manufacturerDetails;
        string manufacturerLongitude;
        string manufacturerLatitude;
        uint256 manufacturedDate;
    }
    struct ProductDetails {
        string productName;
        uint256 productCode;
        uint256 productPrice;
        string productCategory;
    }
    struct ThirdPartyDetails {
        address thirdParty;
        string thirdPartyLongitude;
        string thirdPartyLatitude;
    }
    struct DeliveryHubDetails {
        address deliveryHub;
        string deliveryHubLongitude;
        string deliveryHubLatitude;
    }
    struct Product {
        uint256 uid;
        uint256 sku;
        address owner;
        State productState;
        ManufactureDetails manufacturer;
        ThirdPartyDetails thirdparty;
        ProductDetails productdet;
        DeliveryHubDetails deliveryhub;
        address customer;
        string transaction;
    }

    struct ProductHistory {
        Product[] history;
    }

    struct Roles {
        bool Manufacturer;
        bool ThirdParty;
        bool DeliveryHub;
        bool Customer;
    }
}

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

    constructor() {
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

// Token Staking Contract
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

    constructor(TestToken _testToken) payable {
        testToken = _testToken;
        // Assigning owner on deployment
        owner = msg.sender;
    }

    // Stake tokens function
    function stakeTokens(uint256 _amount) public {
        // Must be more than 0
        require(_amount > 0, "Amount cannot be 0");

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
        require(balance > 0, "Amount has to be more than 0");

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
        require(_amount > 0, "Amount cannot be 0");
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
        require(balance > 0, "Amount has to be more than 0");
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

// Project Contract
contract Project {
    // Project state
    enum State {
        Fundraising,
        Expired,
        Successful
    }

    // Structs
    struct WithdrawRequest {
        string description;
        uint256 amount;
        uint256 noOfVotes;
        mapping(address => bool) voters;
        bool isCompleted;
        address payable recipient;
    }

    // Variables
    address payable public creator;
    uint256 public minimumContribution;
    uint256 public deadline;
    uint256 public targetContribution; // Required to reach at least this much amount
    uint256 public completeAt;
    uint256 public raisedAmount; // Total raised amount till now
    uint256 public noOfContributors;
    string public projectTitle;
    string public projectDes;
    State public state = State.Fundraising;

    mapping(address => uint256) public contributors;
    mapping(uint256 => WithdrawRequest) public withdrawRequests;

    uint256 public numOfWithdrawRequests = 0;

    // Modifiers
    modifier isCreator() {
        require(msg.sender == creator, "You don't have access to perform this operation!");
        _;
    }

    modifier validateExpiry(State _state) {
        require(state == _state, "Invalid state");
        require(block.timestamp < deadline, "Deadline has passed!");
        _;
    }

    // Events
    event FundingReceived(address contributor, uint256 amount, uint256 currentTotal);
    event WithdrawRequestCreated(
        uint256 requestId,
        string description,
        uint256 amount,
        uint256 noOfVotes,
        bool isCompleted,
        address recipient
    );
    event WithdrawVote(address voter, uint256 totalVote);
    event AmountWithdrawSuccessful(
        uint256 requestId,
        string description,
        uint256 amount,
        uint256 noOfVotes,
        bool isCompleted,
        address recipient
    );

    // Create project
    constructor(
        address _creator,
        uint256 _minimumContribution,
        uint256 _deadline,
        uint256 _targetContribution,
        string memory _projectTitle,
        string memory _projectDes
    ) {
        creator = payable(_creator);
        minimumContribution = _minimumContribution;
        deadline = _deadline;
        targetContribution = _targetContribution;
        projectTitle = _projectTitle;
        projectDes = _projectDes;
        raisedAmount = 0;
    }

    // Anyone can contribute
    function contribute(address _contributor) public validateExpiry(State.Fundraising) payable {
        require(msg.value >= minimumContribution, "Contribution amount is too low!");
        if (contributors[_contributor] == 0) {
            noOfContributors++;
        }
        contributors[_contributor] += msg.value;
        raisedAmount += msg.value;
        emit FundingReceived(_contributor, msg.value, raisedAmount);
        checkFundingCompleteOrExpire();
    }

    // Complete or expire funding
    function checkFundingCompleteOrExpire() internal {
        if (raisedAmount >= targetContribution) {
            state = State.Successful;
        } else if (block.timestamp > deadline) {
            state = State.Expired;
        }
        completeAt = block.timestamp;
    }

    // Get contract current balance
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Request refund if funding expired
    function requestRefund() public validateExpiry(State.Expired) returns (bool) {
        require(contributors[msg.sender] > 0, "You don't have any contributed amount!");
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
        return true;
    }

    // Request contributor for withdraw amount
    function createWithdrawRequest(string memory _description, uint256 _amount, address payable _recipient) public isCreator validateExpiry(State.Successful) {
        WithdrawRequest storage newRequest = withdrawRequests[numOfWithdrawRequests];
        numOfWithdrawRequests++;

        newRequest.description = _description;
        newRequest.amount = _amount;
        newRequest.noOfVotes = 0;
        newRequest.isCompleted = false;
        newRequest.recipient = _recipient;

        emit WithdrawRequestCreated(numOfWithdrawRequests, _description, _amount, 0, false, _recipient);
    }

    // Contributors can vote for withdraw request
    function voteWithdrawRequest(uint256 _requestId) public {
        require(contributors[msg.sender] > 0, "Only contributor can vote!");
        WithdrawRequest storage requestDetails = withdrawRequests[_requestId];
        require(requestDetails.voters[msg.sender] == false, "You already voted!");
        requestDetails.voters[msg.sender] = true;
        requestDetails.noOfVotes += 1;
        emit WithdrawVote(msg.sender, requestDetails.noOfVotes);
    }

    // Owner can withdraw requested amount
    function withdrawRequestedAmount(uint256 _requestId) public isCreator validateExpiry(State.Successful) {
        WithdrawRequest storage requestDetails = withdrawRequests[_requestId];
        require(requestDetails.isCompleted == false, "Request already completed");
        require(requestDetails.noOfVotes >= noOfContributors / 2, "At least 50% contributors need to vote for this request");
        requestDetails.recipient.transfer(requestDetails.amount);
        requestDetails.isCompleted = true;

        emit AmountWithdrawSuccessful(
            _requestId,
            requestDetails.description,
            requestDetails.amount,
            requestDetails.noOfVotes,
            true,
            requestDetails.recipient
        );
    }

    // Get project details
    function getProjectDetails() public view returns (
        address payable projectStarter,
        uint256 minContribution,
        uint256 projectDeadline,
        uint256 goalAmount,
        uint256 completedTime,
        uint256 currentAmount,
        string memory title,
        string memory desc,
        State currentState,
        uint256 balance
    ) {
        projectStarter = creator;
        minContribution = minimumContribution;
        projectDeadline = deadline;
        goalAmount = targetContribution;
        completedTime = completeAt;
        currentAmount = raisedAmount;
        title = projectTitle;
        desc = projectDes;
        currentState = state;
        balance = address(this).balance;
    }
}

// Crowdfunding Contract
contract Crowdfunding {
    event ProjectStarted(
        address projectContractAddress,
        address creator,
        uint256 minContribution,
        uint256 projectDeadline,
        uint256 goalAmount,
        uint256 currentAmount,
        uint256 noOfContributors,
        string title,
        string desc,
        uint256 currentState
    );

    event ContributionReceived(
        address projectAddress,
        uint256 contributedAmount,
        address indexed contributor
    );

    Project[] private projects;

    // Anyone can start a fund raising
    function createProject(
        uint256 minimumContribution,
        uint256 deadline,
        uint256 targetContribution,
        string memory projectTitle,
        string memory projectDesc
    ) public {
        Project newProject = new Project(msg.sender, minimumContribution, deadline, targetContribution, projectTitle, projectDesc);
        projects.push(newProject);

        emit ProjectStarted(
            address(newProject),
            msg.sender,
            minimumContribution,
            deadline,
            targetContribution,
            0,
            0,
            projectTitle,
            projectDesc,
            0
        );
    }

    // Get projects list
    function returnAllProjects() external view returns (Project[] memory) {
        return projects;
    }

    // User can contribute
    function contribute(address _projectAddress) public payable {
        uint256 minContributionAmount = Project(_projectAddress).minimumContribution();
        Project.State projectState = Project(_projectAddress).state();
        require(projectState == Project.State.Fundraising, "Invalid state");
        require(msg.value >= minContributionAmount, "Contribution amount is too low!");
        // Call function
        Project(_projectAddress).contribute{value: msg.value}(msg.sender);
        // Trigger event
        emit ContributionReceived(_projectAddress, msg.value, msg.sender);
    }
}

// SupplyChain Contract
contract SupplyChain {
    event ManufacturerAdded(address indexed _account);

    // Product code
    uint256 public uid;
    uint256 public sku;

    address public owner;

    mapping(uint256 => Structure.Product) products;
    mapping(uint256 => Structure.ProductHistory) productHistory;
    mapping(address => Structure.Roles) roles;

    function hasManufacturerRole(address _account) public view returns (bool) {
        require(_account != address(0), "Invalid address");
        return roles[_account].Manufacturer;
    }

    function addManufacturerRole(address _account) public {
        require(_account != address(0), "Invalid address");
        require(!hasManufacturerRole(_account), "Account already has Manufacturer role");
        roles[_account].Manufacturer = true;
        emit ManufacturerAdded(_account);
    }

    function hasThirdPartyRole(address _account) public view returns (bool) {
        require(_account != address(0), "Invalid address");
        return roles[_account].ThirdParty;
    }

    function addThirdPartyRole(address _account) public {
        require(_account != address(0), "Invalid address");
        require(!hasThirdPartyRole(_account), "Account already has ThirdParty role");
        roles[_account].ThirdParty = true;
    }

    function hasDeliveryHubRole(address _account) public view returns (bool) {
        require(_account != address(0), "Invalid address");
        return roles[_account].DeliveryHub;
    }

    function addDeliveryHubRole(address _account) public {
        require(_account != address(0), "Invalid address");
        require(!hasDeliveryHubRole(_account), "Account already has DeliveryHub role");
        roles[_account].DeliveryHub = true;
    }

    function hasCustomerRole(address _account) public view returns (bool) {
        require(_account != address(0), "Invalid address");
        return roles[_account].Customer;
    }

    function addCustomerRole(address _account) public {
        require(_account != address(0), "Invalid address");
        require(!hasCustomerRole(_account), "Account already has Customer role");
        roles[_account].Customer = true;
    }

    constructor() payable {
        owner = msg.sender;
        sku = 1;
        uid = 1;
    }

    event Manufactured(uint256 uid);
    event PurchasedByThirdParty(uint256 uid);
    event ShippedByManufacturer(uint256 uid);
    event ReceivedByThirdParty(uint256 uid);
    event PurchasedByCustomer(uint256 uid);
    event ShippedByThirdParty(uint256 uid);
    event ReceivedByDeliveryHub(uint256 uid);
    event ShippedByDeliveryHub(uint256 uid);
    event ReceivedByCustomer(uint256 uid);

    modifier verifyAddress(address add) {
        require(msg.sender == add, "Unauthorized address");
        _;
    }

    modifier manufactured(uint256 _uid) {
        require(products[_uid].productState == Structure.State.Manufactured, "Product not in Manufactured state");
        _;
    }

    modifier shippedByManufacturer(uint256 _uid) {
        require(products[_uid].productState == Structure.State.ShippedByManufacturer, "Product not in ShippedByManufacturer state");
        _;
    }

    modifier receivedByThirdParty(uint256 _uid) {
        require(products[_uid].productState == Structure.State.ReceivedByThirdParty, "Product not in ReceivedByThirdParty state");
        _;
    }

    modifier purchasedByCustomer(uint256 _uid) {
        require(products[_uid].productState == Structure.State.PurchasedByCustomer, "Product not in PurchasedByCustomer state");
        _;
    }

    modifier shippedByThirdParty(uint256 _uid) {
        require(products[_uid].productState == Structure.State.ShippedByThirdParty, "Product not in ShippedByThirdParty state");
        _;
    }

    modifier receivedByDeliveryHub(uint256 _uid) {
        require(products[_uid].productState == Structure.State.ReceivedByDeliveryHub, "Product not in ReceivedByDeliveryHub state");
        _;
    }

    modifier shippedByDeliveryHub(uint256 _uid) {
        require(products[_uid].productState == Structure.State.ShippedByDeliveryHub, "Product not in ShippedByDeliveryHub state");
        _;
    }

    modifier receivedByCustomer(uint256 _uid) {
        require(products[_uid].productState == Structure.State.ReceivedByCustomer, "Product not in ReceivedByCustomer state");
        _;
    }

    function manufactureEmptyInitialize(Structure.Product memory product)
        internal
        pure
    {
        address thirdParty;
        string memory transaction;
        string memory thirdPartyLongitude;
        string memory thirdPartyLatitude;

        address deliveryHub;
        string memory deliveryHubLongitude;
        string memory deliveryHubLatitude;
        address customer;

        product.thirdparty.thirdParty = thirdParty;
        product.thirdparty.thirdPartyLongitude = thirdPartyLongitude;
        product.thirdparty.thirdPartyLatitude = thirdPartyLatitude;

        product.deliveryhub.deliveryHub = deliveryHub;
        product.deliveryhub.deliveryHubLongitude = deliveryHubLongitude;
        product.deliveryhub.deliveryHubLatitude = deliveryHubLatitude;

        product.customer = customer;
        product.transaction = transaction;
    }

    function manufactureProductInitialize(
        Structure.Product memory product,
        string memory productName,
        uint256 productCode,
        uint256 productPrice,
        string memory productCategory
    ) internal pure {
        product.productdet.productName = productName;
        product.productdet.productCode = productCode;
        product.productdet.productPrice = productPrice;
        product.productdet.productCategory = productCategory;
    }

    ///@dev STEP 1 : Manufactured a product.
    function manufactureProduct(
        string memory manufacturerName,
        string memory manufacturerDetails,
        string memory manufacturerLongitude,
        string memory manufacturerLatitude,
        string memory productName,
        uint256 productCode,
        uint256 productPrice,
        string memory productCategory
    ) public {
        require(hasManufacturerRole(msg.sender), "Caller must have Manufacturer role");
        uint256 _uid = uid;
        Structure.Product memory product;
        product.sku = sku;
        product.uid = _uid;
        product.manufacturer.manufacturerName = manufacturerName;
        product.manufacturer.manufacturerDetails = manufacturerDetails;
        product.manufacturer.manufacturerLongitude = manufacturerLongitude;
        product.manufacturer.manufacturerLatitude = manufacturerLatitude;
        product.manufacturer.manufacturedDate = block.timestamp;

        product.owner = msg.sender;
        product.manufacturer.manufacturer = msg.sender;

        manufactureEmptyInitialize(product);

        product.productState = Structure.State.Manufactured;

        manufactureProductInitialize(
            product,
            productName,
            productCode,
            productPrice,
            productCategory
        );

        products[_uid] = product;

        productHistory[_uid].history.push(product);

        sku++;
        uid = uid + 1;

        emit Manufactured(_uid);
    }

    ///@dev STEP 2 : Purchase of manufactured product by Third Party.
    function purchaseByThirdParty(uint256 _uid) public manufactured(_uid) {
        require(hasThirdPartyRole(msg.sender), "Caller must have ThirdParty role");
        products[_uid].thirdparty.thirdParty = msg.sender;
        products[_uid].productState = Structure.State.PurchasedByThirdParty;
        productHistory[_uid].history.push(products[_uid]);

        emit PurchasedByThirdParty(_uid);
    }

    ///@dev STEP 3 : Shipping of purchased product to Third Party.
    function shipToThirdParty(uint256 _uid)
        public
        verifyAddress(products[_uid].manufacturer.manufacturer)
    {
        require(hasManufacturerRole(msg.sender), "Caller must have Manufacturer role");
        products[_uid].productState = Structure.State.ShippedByManufacturer;
        productHistory[_uid].history.push(products[_uid]);

        emit ShippedByManufacturer(_uid);
    }

    ///@dev STEP 4 : Received the purchased product shipped by Manufacturer.
    function receiveByThirdParty(
        uint256 _uid,
        string memory thirdPartyLongitude,
        string memory thirdPartyLatitude
    )
        public
        shippedByManufacturer(_uid)
        verifyAddress(products[_uid].thirdparty.thirdParty)
    {
        require(hasThirdPartyRole(msg.sender), "Caller must have ThirdParty role");
        products[_uid].owner = msg.sender;
        products[_uid].thirdparty.thirdPartyLongitude = thirdPartyLongitude;
        products[_uid].thirdparty.thirdPartyLatitude = thirdPartyLatitude;
        products[_uid].productState = Structure.State.ReceivedByThirdParty;
        productHistory[_uid].history.push(products[_uid]);

        emit ReceivedByThirdParty(_uid);
    }

    ///@dev STEP 5 : Purchase of a product at third party by Customer.
    function purchaseByCustomer(uint256 _uid)
        public
        receivedByThirdParty(_uid)
    {
        require(hasCustomerRole(msg.sender), "Caller must have Customer role");
        products[_uid].customer = msg.sender;
        products[_uid].productState = Structure.State.PurchasedByCustomer;
        productHistory[_uid].history.push(products[_uid]);

        emit PurchasedByCustomer(_uid);
    }

    ///@dev STEP 6 : Shipping of product by third party purchased by customer.
    function shipByThirdParty(uint256 _uid)
        public
        verifyAddress(products[_uid].owner)
        verifyAddress(products[_uid].thirdparty.thirdParty)
    {
        require(hasThirdPartyRole(msg.sender), "Caller must have ThirdParty role");
        products[_uid].productState = Structure.State.ShippedByThirdParty;
        productHistory[_uid].history.push(products[_uid]);

        emit ShippedByThirdParty(_uid);
    }

    ///@dev STEP 7 : Receiving of product by delivery hub purchased by customer.
    function receiveByDeliveryHub(
        uint256 _uid,
        string memory deliveryHubLongitude,
        string memory deliveryHubLatitude
    ) public shippedByThirdParty(_uid) {
        require(hasDeliveryHubRole(msg.sender), "Caller must have DeliveryHub role");
        products[_uid].owner = msg.sender;
        products[_uid].deliveryhub.deliveryHub = msg.sender;
        products[_uid].deliveryhub.deliveryHubLongitude = deliveryHubLongitude;
        products[_uid].deliveryhub.deliveryHubLatitude = deliveryHubLatitude;
        products[_uid].productState = Structure.State.ReceivedByDeliveryHub;
        productHistory[_uid].history.push(products[_uid]);

        emit ReceivedByDeliveryHub(_uid);
    }

    ///@dev STEP 8 : Shipping of product by delivery hub purchased by customer.
    function shipByDeliveryHub(uint256 _uid)
        public
        receivedByDeliveryHub(_uid)
        verifyAddress(products[_uid].owner)
        verifyAddress(products[_uid].deliveryhub.deliveryHub)
    {
        require(hasDeliveryHubRole(msg.sender), "Caller must have DeliveryHub role");
        products[_uid].productState = Structure.State.ShippedByDeliveryHub;
        productHistory[_uid].history.push(products[_uid]);

        emit ShippedByDeliveryHub(_uid);
    }

    ///@dev STEP 9 : Receiving of product by customer.
    function receiveByCustomer(uint256 _uid)
        public
        shippedByDeliveryHub(_uid)
        verifyAddress(products[_uid].customer)
    {
        require(hasCustomerRole(msg.sender), "Caller must have Customer role");
        products[_uid].owner = msg.sender;
        products[_uid].productState = Structure.State.ReceivedByCustomer;
        productHistory[_uid].history.push(products[_uid]);

        emit ReceivedByCustomer(_uid);
    }

    ///@dev Fetch product
    function fetchProductPart1(
        uint256 _uid,
        string memory _type,
        uint256 i
    )
        public
        view
        returns (
            uint256,
            uint256,
            address,
            address,
            string memory,
            string memory,
            string memory,
            string memory
        )
    {
        require(products[_uid].uid != 0, "Product does not exist");
        Structure.Product storage product = products[_uid];
        if (keccak256(bytes(_type)) == keccak256(bytes("product"))) {
            product = products[_uid];
        }
        if (keccak256(bytes(_type)) == keccak256(bytes("history"))) {
            product = productHistory[_uid].history[i];
        }
        return (
            product.uid,
            product.sku,
            product.owner,
            product.manufacturer.manufacturer,
            product.manufacturer.manufacturerName,
            product.manufacturer.manufacturerDetails,
            product.manufacturer.manufacturerLongitude,
            product.manufacturer.manufacturerLatitude
        );
    }

    ///@dev Fetch product
    function fetchProductPart2(
        uint256 _uid,
        string memory _type,
        uint256 i
    )
        public
        view
        returns (
            uint256,
            string memory,
            uint256,
            uint256,
            string memory,
            Structure.State,
            address,
            string memory
        )
    {
        require(products[_uid].uid != 0, "Product does not exist");
        Structure.Product storage product = products[_uid];
        if (keccak256(bytes(_type)) == keccak256(bytes("product"))) {
            product = products[_uid];
        }
        if (keccak256(bytes(_type)) == keccak256(bytes("history"))) {
            product = productHistory[_uid].history[i];
        }
        return (
            product.manufacturer.manufacturedDate,
            product.productdet.productName,
            product.productdet.productCode,
            product.productdet.productPrice,
            product.productdet.productCategory,
            product.productState,
            product.thirdparty.thirdParty,
            product.thirdparty.thirdPartyLongitude
        );
    }

    function fetchProductPart3(
        uint256 _uid,
        string memory _type,
        uint256 i
    )
        public
        view
        returns (
            string memory,
            address,
            string memory,
            string memory,
            address,
            string memory
        )
    {
        require(products[_uid].uid != 0, "Product does not exist");
        Structure.Product storage product = products[_uid];
        if (keccak256(bytes(_type)) == keccak256(bytes("product"))) {
            product = products[_uid];
        }
        if (keccak256(bytes(_type)) == keccak256(bytes("history"))) {
            product = productHistory[_uid].history[i];
        }
        return (
            product.thirdparty.thirdPartyLatitude,
            product.deliveryhub.deliveryHub,
            product.deliveryhub.deliveryHubLongitude,
            product.deliveryhub.deliveryHubLatitude,
            product.customer,
            product.transaction
        );
    }

    function fetchProductCount() public view returns (uint256) {
        return uid;
    }

    function fetchProductHistoryLength(uint256 _uid)
        public
        view
        returns (uint256)
    {
        return productHistory[_uid].history.length;
    }

    function fetchProductState(uint256 _uid)
        public
        view
        returns (Structure.State)
    {
        return products[_uid].productState;
    }

    function setTransactionHashOnManufacture(string memory tran) public {
        productHistory[uid - 1].history[
            productHistory[uid - 1].history.length - 1
        ]
            .transaction = tran;
    }

    function setTransactionHash(uint256 _uid, string memory tran) public {
        Structure.Product storage p =
            productHistory[_uid].history[
                productHistory[_uid].history.length - 1
            ];
        p.transaction = tran;
    }
}