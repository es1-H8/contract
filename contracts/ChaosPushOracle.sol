// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

/**
 * @title ChaosPushOracle
 * @author Chaos Labs
 * @dev A decentralized oracle contract that allows trusted oracles to push price updates
 * with multi-signature verification. Upgradable using UUPS proxy pattern.
 */
contract ChaosPushOracle is OwnableUpgradeable, UUPSUpgradeable {
    using ECDSA for bytes32;

    // ============ Custom Errors ============

    error FeedIdMismatch();
    error TimestampTooOld();
    error TimestampTooFar();
    error TimestampNotNewer();
    error InsufficientSignatures();
    error SignerNotTrusted();
    error OracleAlreadyTrusted();
    error OracleNotFound();
    error RoundNotAvailable();
    error RoundExceedsUint80Limit();

    // ============ Structs ============

    struct RoundData {
        int256 price; // Price of the asset
        uint256 reportRoundId; // ID of the report round
        uint256 observedTs; // Timestamp when the observation was made
        uint256 blockNumber; // Block number of the transaction
        uint256 postedTs; // Timestamp when the data was posted
        uint8 numSignatures; // Count of valid signatures for this round
    }

    // ============ State Variables ============

    uint8 public decimals; // Number of decimal places for price
    string public description; // Description of the oracle
    uint80 internal _latestRound; // Tracks the latest round number, initialized to 0
    mapping(uint80 => RoundData) public rounds; // Mapping of round number to RoundData
    mapping(address => bool) public trustedOracles; // Mapping of trusted oracle addresses
    address[] public oracles; // List of all trusted oracles
    address public deprecated_trustedSender; // IMPORTANT: Maintains storage layout compatibility
    string public feedId; // The feed ID this oracle is responsible for

    // ============ Events ============

    /**
     * @dev Emitted when an oracle is added to the trusted list
     */
    event OracleAdded(address indexed oracle);

    /**
     * @dev Emitted when an oracle is removed from the trusted list
     */
    event OracleRemoved(address indexed oracle);

    /**
     * @dev Emitted when a new price update is successfully posted
     */
    event NewPriceUpdate(
        uint80 indexed roundId,
        int256 price,
        uint256 reportRoundId,
        uint256 timestamp,
        address transmitter,
        uint256 numSignatures
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // ============ Initializer ============

    /**
     * @notice Initializes the contract instead of using a constructor
     * @param _decimals Number of decimal places for price
     * @param _description Description of the oracle
     * @param _owner Address of the contract owner
     * @param _oracles Array of initial oracle addresses to be trusted
     */
    function initialize(uint8 _decimals, string memory _description, address _owner, address[] memory _oracles)
        public
        initializer
    {
        __Ownable_init();
        __UUPSUpgradeable_init();

        decimals = _decimals;
        description = _description;
        feedId = "";
        _latestRound = 0;

        // Add initial oracles
        for (uint256 i = 0; i < _oracles.length; i++) {
            address oracle = _oracles[i];
            if (trustedOracles[oracle]) revert OracleAlreadyTrusted();
            trustedOracles[oracle] = true;
            oracles.push(oracle);
        }
    }

    /**
     * @notice Initializes the contract when upgrading from a previous version
     * @param _feedId The feed ID this oracle is responsible for
     */
    function initializeV2(string memory _feedId) external reinitializer(2) onlyOwner {
        feedId = _feedId;
    }

    // ============ Upgrade Authorization ============

    /**
     * @dev Function that authorizes an upgrade to a new implementation.
     * Only the owner can upgrade the contract.
     * @param newImplementation Address of the new implementation contract
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    // ============ Oracle Management Functions ============

    /**
     * @notice Owner can add a trusted oracle
     * @param oracle Address of the oracle to be added
     */
    function addOracle(address oracle) external onlyOwner {
        if (trustedOracles[oracle]) revert OracleAlreadyTrusted();
        trustedOracles[oracle] = true;
        oracles.push(oracle);
        emit OracleAdded(oracle);
    }

    /**
     * @notice Owner can remove a trusted oracle
     * @param oracle Address of the oracle to be removed
     */
    function removeOracle(address oracle) external onlyOwner {
        if (!trustedOracles[oracle]) revert OracleNotFound();
        trustedOracles[oracle] = false;

        // Remove from oracles array
        for (uint256 i = 0; i < oracles.length; i++) {
            if (oracles[i] == oracle) {
                oracles[i] = oracles[oracles.length - 1];
                oracles.pop();
                break;
            }
        }
        emit OracleRemoved(oracle);
    }

    // ============ Update Posting Function ============

    /**
     * @notice Anyone can submit a report signed by multiple trusted oracles
     * @param report Encoded report data (string feedId, int256 price, uint256 reportRoundId, uint256 obsTs)
     * @param signatures Array of signatures from trusted oracles
     */
    function postUpdate(bytes memory report, bytes[] memory signatures) external {
        // Decode report
        (bytes32 reportFeedId, int256 price, uint256 reportRoundId, uint256 observationTs) =
            abi.decode(report, (bytes32, int256, uint256, uint256));

        // Verify feed ID matches
        if (reportFeedId != keccak256(bytes(feedId))) revert FeedIdMismatch();

        // Timestamp checks
        if (observationTs <= rounds[_latestRound].observedTs) revert TimestampNotNewer();
        if (observationTs > block.timestamp + 5 minutes) revert TimestampTooFar();

        uint256 minAllowedTimestamp = block.timestamp > 1 hours ? block.timestamp - 1 hours : 0;
        if (observationTs < minAllowedTimestamp) revert TimestampTooOld();

        // Signature verification
        // The message to be verified is the hash of the raw `report` bytes.
        bytes32 messageHash = keccak256(report);

        // Verify signatures
        uint256 validSignatures = _verifySignatures(messageHash, signatures);
        if (validSignatures < requiredSignatures()) revert InsufficientSignatures();

        // Update round data
        if (_latestRound == type(uint80).max) revert RoundExceedsUint80Limit();
        _latestRound++;

        rounds[_latestRound] = RoundData({
            price: price,
            reportRoundId: reportRoundId,
            observedTs: observationTs,
            blockNumber: block.number,
            postedTs: block.timestamp,
            numSignatures: uint8(validSignatures)
        });

        emit NewPriceUpdate(_latestRound, price, reportRoundId, observationTs, msg.sender, validSignatures);
    }

    /**
     * @dev Internal function to verify multiple signatures
     * @param messageHash The hash of the message being verified
     * @param signatures Array of signatures to verify
     * @return validSignatures Number of valid signatures
     */
    function _verifySignatures(bytes32 messageHash, bytes[] memory signatures) private view returns (uint256) {
        uint256 numSignatures = signatures.length;
        uint256 validSignatures = 0;
        address[] memory signers = new address[](numSignatures);

        for (uint256 i = 0; i < numSignatures; i++) {
            address signer = messageHash.recover(signatures[i]);

            if (!trustedOracles[signer]) revert SignerNotTrusted();

            // Check for duplicates
            bool isDuplicate = false;
            for (uint256 j = 0; j < validSignatures; j++) {
                if (signers[j] == signer) {
                    isDuplicate = true;
                    break;
                }
            }

            if (!isDuplicate) {
                signers[validSignatures] = signer;
                validSignatures++;
            }
        }

        return validSignatures;
    }

    // ============ Utility Functions ============

    /**
     * @notice Returns the number of required signatures (e.g., majority)
     * @return The number of required signatures
     */
    function requiredSignatures() public view returns (uint256) {
        uint256 totalOracles = oracles.length;
        uint256 threshold = (totalOracles * 2 + 2) / 3;
        return threshold > 0 ? threshold : 1;
    }

    // ============ Data Retrieval Functions ============

    /**
     * @notice Get the latest round number
     * @return The latest round number
     */
    function latestRound() external view returns (uint256) {
        return uint256(_latestRound);
    }

    /**
     * @notice Get the price for a specific round
     * @param roundId The round ID to retrieve price for
     * @return The price for the specified round
     */
    function getAnswer(uint256 roundId) external view returns (int256) {
        if (roundId == 0 || roundId > _latestRound) revert RoundNotAvailable();
        return rounds[uint80(roundId)].price;
    }

    /**
     * @notice Get the timestamp for a specific round
     * @param roundId The round ID to retrieve timestamp for
     * @return The timestamp for the specified round
     */
    function getTimestamp(uint256 roundId) external view returns (uint256) {
        if (roundId == 0 || roundId > _latestRound) revert RoundNotAvailable();
        return rounds[uint80(roundId)].postedTs;
    }

    /**
     * @notice Retrieve round data for a specific round
     * @param round The round number to retrieve data for
     * @return price The price for the specified round
     * @return reportRoundId The report round ID
     * @return timestamp The timestamp of the observation
     * @return blockNumber The block number when the round was posted
     */
    function getRoundData(uint80 round)
        external
        view
        returns (int256 price, uint256 reportRoundId, uint256 timestamp, uint256 blockNumber)
    {
        if (round == 0 || round > _latestRound) revert RoundNotAvailable();
        RoundData storage data = rounds[round];
        return (data.price, data.reportRoundId, data.observedTs, data.blockNumber);
    }

    /**
     * @notice Returns details of the latest successful update round
     * @return roundId The number of the latest round
     * @return answer The latest reported value
     * @return startedAt Block timestamp when the latest successful round started
     * @return updatedAt Block timestamp of the latest successful round
     * @return answeredInRound The number of the latest round
     */
    function latestRoundData()
        external
        view
        virtual
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        roundId = uint80(_latestRound);
        answer = latestAnswer();
        RoundData storage data = rounds[_latestRound];
        startedAt = data.observedTs;
        updatedAt = data.postedTs;
        answeredInRound = roundId;
    }

    /**
     * @notice Retrieve the timestamp of the latest round
     * @return timestamp The timestamp of the latest round
     */
    function latestTimestamp() external view returns (uint256 timestamp) {
        return rounds[_latestRound].postedTs;
    }

    // ============ Admin Functions ============

    /**
     * @notice Set the description of the oracle
     * @param _description The new description
     */
    function setDescription(string memory _description) external onlyOwner {
        description = _description;
    }

    /**
     * @notice Set the number of decimals for the answer values
     * @param _decimals The new number of decimals
     */
    function setDecimals(uint8 _decimals) external onlyOwner {
        decimals = _decimals;
    }

    /**
     * @notice Set the feed ID of the oracle
     * @param _feedId The new feed ID
     */
    function setFeedId(string memory _feedId) external onlyOwner {
        feedId = _feedId;
    }

    // ============ Helper Functions ============

    /**
     * @notice Helper function that generates the Ethereum-style message hash
     * @param _data The data to hash
     * @return The keccak256 hash of the data
     */
    function getMessageHash(bytes calldata _data) external pure returns (bytes32) {
        return keccak256(_data);
    }

    /**
     * @notice Chainlink-compatible function for getting the latest successfully reported value
     * @return The latest successfully reported value
     */
    function latestAnswer() public view virtual returns (int256) {
        return rounds[_latestRound].price;
    }
}