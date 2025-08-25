// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Voting contract for managing candidates and their vote counts
contract Voting {
    // Mapping to store vote count for each candidate
    mapping(bytes32 => uint8) public votesReceived;

    // Array to store list of candidate names
    bytes32[] public candidateList;

    // Constructor to initialize the candidate list
    constructor(bytes32[] memory candidateNames) {
        require(candidateNames.length > 0, "Candidate list cannot be empty");
        for (uint i = 0; i < candidateNames.length; i++) {
            require(candidateNames[i] != bytes32(0), "Candidate name cannot be empty");
        }
        candidateList = candidateNames;
    }

    // Returns the total votes a candidate has received
    function totalVotesFor(bytes32 candidate) external view returns (uint8) {
        require(validCandidate(candidate), "Invalid candidate");
        return votesReceived[candidate];
    }

    // Increments the vote count for the specified candidate
    function voteForCandidate(bytes32 candidate) external {
        require(validCandidate(candidate), "Invalid candidate");
        votesReceived[candidate] += 1;
    }

    // Checks if a candidate is valid (exists in candidateList)
    function validCandidate(bytes32 candidate) public view returns (bool) {
        require(candidate != bytes32(0), "Candidate name cannot be empty");
        for (uint i = 0; i < candidateList.length; i++) {
            if (candidateList[i] == candidate) {
                return true;
            }
        }
        return false;
    }

    // Returns the list of candidates
    function getCandidateList() external view returns (bytes32[] memory) {
        return candidateList;
    }
}