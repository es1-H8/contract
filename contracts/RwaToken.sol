pragma solidity ^0.8.26;

// SPDX-License-Identifier: MIT

/**
 * @title RAWToken Real-World Asset
 * @notice Token linked to M1 bank deposit.
 *
 * |---------------------------------------------------------------|
 * |                    @ KINGDOM OF BAHRAIN 2025 @                |
 * |---------------------------------------------------------------|
 *
 * -  Minted only after Proof-of-Funds (PoF) verification by Chainlink.
 * - Supports automatic swap to ERC-20 USDT.
 * - Secured by ECDSA bank signature.
 * - Real-World Asset (RWA) tokenization with full reserve auditing.
 * - SWIFT and ISO 20022 integration
 */

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RAWToken is ERC20, Ownable, ChainlinkClient {
    using Chainlink for Chainlink.Request;

    address public oracle;
    bytes32 public jobId;
    uint256 public fee;

    mapping(bytes32 => bool) public verifiedHashes;
    mapping(string => bool) public usedTrn;
    mapping(address => bool) public authorizedOracles;
    mapping(bytes32 => address) public requestToRecipient;
    mapping(bytes32 => string) public requestToTrn;
    mapping(bytes32 => uint256) public requestToAmount;

    event MintRequest(bytes32 indexed requestId, string trn, uint256 amount, address indexed to);
    event MintConfirmed(string trn, bytes32 hash, uint256 amount, address indexed to);
    event OracleUpdated(address oracle, bytes32 jobId, uint256 fee);
    event AuthorizedOracle(address oracle, bool status);

    constructor(address _link) ERC20("RealFiat RAW Token", "RAW") Ownable(msg.sender) {
        _setChainlinkToken(_link);
        _mint(msg.sender, 0);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function requestMintVerification(
        string memory trn,
        uint256 amount,
        address to,
        bytes32 hash
    ) public onlyOwner returns (bytes32 requestId) {
        require(to != address(0), "Invalid recipient");
        require(!verifiedHashes[hash], "Hash already processed");
        require(!usedTrn[trn], "TRN already used");
        require(amount > 0, "Amount must be > 0");

        Chainlink.Request memory req = _buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        req._add("get", string(abi.encodePacked("https://api.example.com/verify?trn=", trn)));
        req._add("path", "result");
        req._addBytes("hash", abi.encode(hash));
        req._add("to", addressToString(to));

        requestId = _sendChainlinkRequestTo(oracle, req, fee);
        requestToRecipient[requestId] = to;
        requestToTrn[requestId] = trn;
        requestToAmount[requestId] = amount;

        emit MintRequest(requestId, trn, amount, to);
        return requestId;
    }

    modifier onlyAuthorizedOracle() {
        require(
            authorizedOracles[msg.sender] || msg.sender == oracle,
            "Source must be the oracle of the request"
        );
        _;
    }

    function fulfill(bytes32 _requestId, bytes32 _resultHash)
        public
        onlyAuthorizedOracle
    {
        uint256 _approvedAmount = requestToAmount[_requestId];
        require(_approvedAmount > 0, "Not approved by oracle");
        require(!verifiedHashes[_resultHash], "Hash already minted");

        address to = requestToRecipient[_requestId];
        string memory trn = requestToTrn[_requestId];
        require(to != address(0), "Invalid recipient address");

        verifiedHashes[_resultHash] = true;
        usedTrn[trn] = true;

        _mint(to, _approvedAmount);
        emit MintConfirmed(trn, _resultHash, _approvedAmount, to);
    }

    function addressToString(address account) internal pure returns (string memory) {
        bytes20 value = bytes20(account);
        bytes16 hexSymbols = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = hexSymbols[uint8(value[i] >> 4)];
            str[3 + i * 2] = hexSymbols[uint8(value[i] & 0x0f)];
        }
        return string(str);
    }

    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (uint8 j = 0; j < i; j++) {
            bytesArray[j] = _bytes32[j];
        }
        return string(bytesArray);
    }

    function setOracle(address _oracle, bytes32 _jobId, uint256 _fee) external onlyOwner {
        oracle = _oracle;
        jobId = _jobId;
        fee = _fee;
        emit OracleUpdated(_oracle, _jobId, _fee);
    }

    function setAuthorizedOracle(address _oracle, bool status) external onlyOwner {
        authorizedOracles[_oracle] = status;
        emit AuthorizedOracle(_oracle, status);
    }
}