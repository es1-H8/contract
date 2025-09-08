// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SupplyChain is Ownable {
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

    uint256 public uid = 1;
    uint256 public sku = 1;
    mapping(uint256 => Product) internal products;
    mapping(uint256 => ProductHistory) internal productHistory;
    mapping(address => Roles) public roles;
    mapping(uint256 => bool) public productExists;

    event ManufacturerAdded(address indexed account);
    event Manufactured(uint256 indexed uid, address indexed owner, uint256 timestamp);
    event PurchasedByThirdParty(uint256 indexed uid, address indexed thirdParty, uint256 timestamp);
    event ShippedByManufacturer(uint256 indexed uid, address indexed manufacturer, uint256 timestamp);
    event ReceivedByThirdParty(uint256 indexed uid, address indexed thirdParty, uint256 timestamp);
    event PurchasedByCustomer(uint256 indexed uid, address indexed customer, uint256 timestamp);
    event ShippedByThirdParty(uint256 indexed uid, address indexed thirdParty, uint256 timestamp);
    event ReceivedByDeliveryHub(uint256 indexed uid, address indexed deliveryHub, uint256 timestamp);
    event ShippedByDeliveryHub(uint256 indexed uid, address indexed deliveryHub, uint256 timestamp);
    event ReceivedByCustomer(uint256 indexed uid, address indexed customer, uint256 timestamp);

    constructor() Ownable() {
        // Initialize owner, sku, and uid
    }

    modifier verifyAddress(address add) {
        require(msg.sender == add, "Unauthorized address");
        _;
    }

    modifier manufactured(uint256 _uid) {
        require(productExists[_uid], "Product does not exist");
        require(products[_uid].productState == State.Manufactured, "Product not in Manufactured state");
        _;
    }

    modifier shippedByManufacturer(uint256 _uid) {
        require(productExists[_uid], "Product does not exist");
        require(products[_uid].productState == State.ShippedByManufacturer, "Product not in ShippedByManufacturer state");
        _;
    }

    modifier receivedByThirdParty(uint256 _uid) {
        require(productExists[_uid], "Product does not exist");
        require(products[_uid].productState == State.ReceivedByThirdParty, "Product not in ReceivedByThirdParty state");
        _;
    }

    modifier purchasedByCustomer(uint256 _uid) {
        require(productExists[_uid], "Product does not exist");
        require(products[_uid].productState == State.PurchasedByCustomer, "Product not in PurchasedByCustomer state");
        _;
    }

    modifier shippedByThirdParty(uint256 _uid) {
        require(productExists[_uid], "Product does not exist");
        require(products[_uid].productState == State.ShippedByThirdParty, "Product not in ShippedByThirdParty state");
        _;
    }

    modifier receivedByDeliveryHub(uint256 _uid) {
        require(productExists[_uid], "Product does not exist");
        require(products[_uid].productState == State.ReceivedByDeliveryHub, "Product not in ReceivedByDeliveryHub state");
        _;
    }

    modifier shippedByDeliveryHub(uint256 _uid) {
        require(productExists[_uid], "Product does not exist");
        require(products[_uid].productState == State.ShippedByDeliveryHub, "Product not in ShippedByDeliveryHub state");
        _;
    }

    function hasManufacturerRole(address _account) public view returns (bool) {
        require(_account != address(0), "Invalid address");
        return roles[_account].Manufacturer;
    }

    function addManufacturerRole(address _account) external onlyOwner {
        require(_account != address(0), "Invalid address");
        require(!hasManufacturerRole(_account), "Account already has Manufacturer role");
        roles[_account].Manufacturer = true;
        emit ManufacturerAdded(_account);
    }

    function hasThirdPartyRole(address _account) public view returns (bool) {
        require(_account != address(0), "Invalid address");
        return roles[_account].ThirdParty;
    }

    function addThirdPartyRole(address _account) external onlyOwner {
        require(_account != address(0), "Invalid address");
        require(!hasThirdPartyRole(_account), "Account already has ThirdParty role");
        roles[_account].ThirdParty = true;
    }

    function hasDeliveryHubRole(address _account) public view returns (bool) {
        require(_account != address(0), "Invalid address");
        return roles[_account].DeliveryHub;
    }

    function addDeliveryHubRole(address _account) external onlyOwner {
        require(_account != address(0), "Invalid address");
        require(!hasDeliveryHubRole(_account), "Account already has DeliveryHub role");
        roles[_account].DeliveryHub = true;
    }

    function hasCustomerRole(address _account) public view returns (bool) {
        require(_account != address(0), "Invalid address");
        return roles[_account].Customer;
    }

    function addCustomerRole(address _account) external onlyOwner {
        require(_account != address(0), "Invalid address");
        require(!hasCustomerRole(_account), "Account already has Customer role");
        roles[_account].Customer = true;
    }

    function manufactureProduct(
        string memory manufacturerName,
        string memory manufacturerDetails,
        string memory manufacturerLongitude,
        string memory manufacturerLatitude,
        string memory productName,
        uint256 productCode,
        uint256 productPrice,
        string memory productCategory
    ) external {
        require(hasManufacturerRole(msg.sender), "Caller is not a Manufacturer");
        uint256 _uid = uid;
        Product memory product = Product({
            sku: sku,
            uid: _uid,
            owner: msg.sender,
            productState: State.Manufactured,
            manufacturer: ManufactureDetails({
                manufacturer: msg.sender,
                manufacturerName: manufacturerName,
                manufacturerDetails: manufacturerDetails,
                manufacturerLongitude: manufacturerLongitude,
                manufacturerLatitude: manufacturerLatitude,
                manufacturedDate: block.timestamp
            }),
            thirdparty: ThirdPartyDetails({
                thirdParty: address(0),
                thirdPartyLongitude: "",
                thirdPartyLatitude: ""
            }),
            productdet: ProductDetails({
                productName: productName,
                productCode: productCode,
                productPrice: productPrice,
                productCategory: productCategory
            }),
            deliveryhub: DeliveryHubDetails({
                deliveryHub: address(0),
                deliveryHubLongitude: "",
                deliveryHubLatitude: ""
            }),
            customer: address(0),
            transaction: ""
        });

        products[_uid] = product;
        productHistory[_uid].history.push(product);
        productExists[_uid] = true;

        sku++;
        uid++;

        emit Manufactured(_uid, msg.sender, block.timestamp);
    }

    function purchaseByThirdParty(uint256 _uid) external manufactured(_uid) {
        require(hasThirdPartyRole(msg.sender), "Caller is not a ThirdParty");
        products[_uid].thirdparty.thirdParty = msg.sender;
        products[_uid].productState = State.PurchasedByThirdParty;
        productHistory[_uid].history.push(products[_uid]);
        emit PurchasedByThirdParty(_uid, msg.sender, block.timestamp);
    }

    function shipToThirdParty(uint256 _uid)
        external
        verifyAddress(products[_uid].manufacturer.manufacturer)
    {
        require(hasManufacturerRole(msg.sender), "Caller is not a Manufacturer");
        products[_uid].productState = State.ShippedByManufacturer;
        productHistory[_uid].history.push(products[_uid]);
        emit ShippedByManufacturer(_uid, msg.sender, block.timestamp);
    }

    function receiveByThirdParty(
        uint256 _uid,
        string memory thirdPartyLongitude,
        string memory thirdPartyLatitude
    )
        external
        shippedByManufacturer(_uid)
        verifyAddress(products[_uid].thirdparty.thirdParty)
    {
        require(hasThirdPartyRole(msg.sender), "Caller is not a ThirdParty");
        products[_uid].owner = msg.sender;
        products[_uid].thirdparty.thirdPartyLongitude = thirdPartyLongitude;
        products[_uid].thirdparty.thirdPartyLatitude = thirdPartyLatitude;
        products[_uid].productState = State.ReceivedByThirdParty;
        productHistory[_uid].history.push(products[_uid]);
        emit ReceivedByThirdParty(_uid, msg.sender, block.timestamp);
    }

    function purchaseByCustomer(uint256 _uid)
        external
        receivedByThirdParty(_uid)
    {
        require(hasCustomerRole(msg.sender), "Caller is not a Customer");
        products[_uid].customer = msg.sender;
        products[_uid].productState = State.PurchasedByCustomer;
        productHistory[_uid].history.push(products[_uid]);
        emit PurchasedByCustomer(_uid, msg.sender, block.timestamp);
    }

    function shipByThirdParty(uint256 _uid)
        external
        verifyAddress(products[_uid].owner)
        verifyAddress(products[_uid].thirdparty.thirdParty)
    {
        require(hasThirdPartyRole(msg.sender), "Caller is not a ThirdParty");
        products[_uid].productState = State.ShippedByThirdParty;
        productHistory[_uid].history.push(products[_uid]);
        emit ShippedByThirdParty(_uid, msg.sender, block.timestamp);
    }

    function receiveByDeliveryHub(
        uint256 _uid,
        string memory deliveryHubLongitude,
        string memory deliveryHubLatitude
    ) external shippedByThirdParty(_uid) {
        require(hasDeliveryHubRole(msg.sender), "Caller is not a DeliveryHub");
        products[_uid].owner = msg.sender;
        products[_uid].deliveryhub.deliveryHub = msg.sender;
        products[_uid].deliveryhub.deliveryHubLongitude = deliveryHubLongitude;
        products[_uid].deliveryhub.deliveryHubLatitude = deliveryHubLatitude;
        products[_uid].productState = State.ReceivedByDeliveryHub;
        productHistory[_uid].history.push(products[_uid]);
        emit ReceivedByDeliveryHub(_uid, msg.sender, block.timestamp);
    }

    function shipByDeliveryHub(uint256 _uid)
        external
        receivedByDeliveryHub(_uid)
        verifyAddress(products[_uid].owner)
        verifyAddress(products[_uid].deliveryhub.deliveryHub)
    {
        require(hasDeliveryHubRole(msg.sender), "Caller is not a DeliveryHub");
        products[_uid].productState = State.ShippedByDeliveryHub;
        productHistory[_uid].history.push(products[_uid]);
        emit ShippedByDeliveryHub(_uid, msg.sender, block.timestamp);
    }

    function receiveByCustomer(uint256 _uid)
        external
        shippedByDeliveryHub(_uid)
        verifyAddress(products[_uid].customer)
    {
        require(hasCustomerRole(msg.sender), "Caller is not a Customer");
        products[_uid].owner = msg.sender;
        products[_uid].productState = State.ReceivedByCustomer;
        productHistory[_uid].history.push(products[_uid]);
        emit ReceivedByCustomer(_uid, msg.sender, block.timestamp);
    }

    function fetchProductPart1(
        uint256 _uid,
        string memory _type,
        uint256 i
    )
        external
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
        require(productExists[_uid], "Product does not exist");
        Product memory product = products[_uid];
        if (keccak256(bytes(_type)) == keccak256(bytes("history"))) {
            require(i < productHistory[_uid].history.length, "Invalid history index");
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

    function fetchProductPart2(
        uint256 _uid,
        string memory _type,
        uint256 i
    )
        external
        view
        returns (
            uint256,
            string memory,
            uint256,
            uint256,
            string memory,
            State,
            address,
            string memory
        )
    {
        require(productExists[_uid], "Product does not exist");
        Product memory product = products[_uid];
        if (keccak256(bytes(_type)) == keccak256(bytes("history"))) {
            require(i < productHistory[_uid].history.length, "Invalid history index");
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
        external
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
        require(productExists[_uid], "Product does not exist");
        Product memory product = products[_uid];
        if (keccak256(bytes(_type)) == keccak256(bytes("history"))) {
            require(i < productHistory[_uid].history.length, "Invalid history index");
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

    function fetchProductCount() external view returns (uint256) {
        return uid;
    }

    function fetchProductHistoryLength(uint256 _uid) external view returns (uint256) {
        require(productExists[_uid], "Product does not exist");
        return productHistory[_uid].history.length;
    }

    function fetchProductState(uint256 _uid) external view returns (State) {
        require(productExists[_uid], "Product does not exist");
        return products[_uid].productState;
    }

    function setTransactionHashOnManufacture(string memory tran) external onlyOwner {
        require(productExists[uid - 1], "Product does not exist");
        productHistory[uid - 1].history[productHistory[uid - 1].history.length - 1].transaction = tran;
    }

    function setTransactionHash(uint256 _uid, string memory tran) external onlyOwner {
        require(productExists[_uid], "Product does not exist");
        productHistory[_uid].history[productHistory[_uid].history.length - 1].transaction = tran;
    }
}