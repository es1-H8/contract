// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Voting contract for managing candidates and votes
contract Voting {
    // Event for when a candidate is added
    event AddedCandidate(uint indexed candidateID);

    // Contract owner
    address public owner;

    // Modifier to restrict access to owner
    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Struct for Voter
    struct Voter {
        bytes32 uid; // Unique identifier for voter
        uint candidateIDVote; // ID of candidate voted for
    }

    // Struct for Candidate
    struct Candidate {
        bytes32 name; // Candidate name
        bytes32 party; // Candidate party
        bool doesExist; // Flag to check if candidate exists
    }

    // State variables to track counts
    uint public numCandidates;
    uint public numVoters;

    // Mappings for candidates and voters
    mapping(uint => Candidate) public candidates;
    mapping(uint => Voter) public voters;
    // Added to track used voter UIDs to prevent duplicate voting
    mapping(bytes32 => bool) private usedUids;

    // Constructor to set the owner
    constructor() {
        owner = msg.sender;
    }

    // Add a new candidate (only owner)
    function addCandidate(bytes32 name, bytes32 party) external onlyOwner {
        require(name != bytes32(0), "Candidate name cannot be empty");
        require(party != bytes32(0), "Party name cannot be empty");

        uint candidateID = numCandidates++;
        candidates[candidateID] = Candidate(name, party, true);
        emit AddedCandidate(candidateID);
    }

    // Cast a vote for a candidate
    function vote(bytes32 uid, uint candidateID) external {
        require(candidates[candidateID].doesExist, "Candidate does not exist");
        require(uid != bytes32(0), "Voter UID cannot be empty");
        require(!usedUids[uid], "Voter UID already used");

        uint voterID = numVoters++;
        voters[voterID] = Voter(uid, candidateID);
        usedUids[uid] = true; // Mark UID as used
    }

    // Get total votes for a candidate
    function totalVotes(uint candidateID) external view returns (uint) {
        require(candidates[candidateID].doesExist, "Candidate does not exist");
        uint numOfVotes = 0;
        for (uint i = 0; i < numVoters; i++) {
            if (voters[i].candidateIDVote == candidateID) {
                numOfVotes++;
            }
        }
        return numOfVotes;
    }

    // Get number of candidates
    function getNumOfCandidates() external view returns (uint) {
        return numCandidates;
    }

    // Get number of voters
    function getNumOfVoters() external view returns (uint) {
        return numVoters;
    }

    // Get candidate details
    function getCandidate(uint candidateID) external view returns (uint, bytes32, bytes32) {
        require(candidates[candidateID].doesExist, "Candidate does not exist");
        return (candidateID, candidates[candidateID].name, candidates[candidateID].party);
    }
}