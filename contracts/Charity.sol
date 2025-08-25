// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CharityFactory {
    struct Charity {
        address owner;
        address recipient;
        string title;
        string desc;
        uint targetAmount;
        uint balance;
        uint deadline;
        bool isCompleted;
    }

    mapping(address => Charity[]) public charityData;
    Charity[] public allCharities;

    event CharityCreated(address indexed owner, uint indexed charityId);
    event DonateSuccess(address indexed donator, uint indexed charityId, uint256 amount);
    event CharitySended(address indexed owner, address indexed recipient, uint indexed charityId, uint256 amount);
    event CharityClosed(address indexed owner, uint indexed charityId);

    function createCharity(
        string memory _title,
        string memory _desc,
        address _recipient,
        uint _targetAmount,
        uint _deadline
    ) external {
        require(_deadline > block.timestamp, "Deadline must be in the future");
        require(_targetAmount > 0, "Target must be more than zero");
        require(_recipient != address(0), "Invalid address");

        Charity memory newCharity = Charity({
            owner: msg.sender,
            recipient: _recipient,
            title: _title,
            desc: _desc,
            targetAmount: _targetAmount,
            balance: 0,
            deadline: _deadline,
            isCompleted: false
        });

        charityData[msg.sender].push(newCharity);
        allCharities.push(newCharity);

        emit CharityCreated(msg.sender, allCharities.length - 1);
    }

    function donate(uint _charityId) external payable {
        require(_charityId < allCharities.length, "Invalid charity ID");
        Charity storage charity = allCharities[_charityId];
        require(msg.value > 0, "Must send ether!");
        require(!charity.isCompleted, "Charity donations are closed!");
        require(block.timestamp <= charity.deadline, "Charity donations are closed!");

        charity.balance += msg.value;

        emit DonateSuccess(msg.sender, _charityId, msg.value);
    }

    function sendCharity(uint _charityId) external payable {
        require(_charityId < allCharities.length, "Invalid charity ID");
        Charity storage charity = allCharities[_charityId];
        require(msg.sender == charity.owner, "You are not the owner!");
        require(!charity.isCompleted, "Charity is already completed!");
        require(charity.balance > 0, "No funds to send!");
        require(block.timestamp > charity.deadline, "Charity is still active!");

        uint amount = charity.balance;
        charity.balance = 0;

        (bool success, ) = charity.recipient.call{value: amount}("");
        require(success, "Transfer failed");

        emit CharitySended(msg.sender, charity.recipient, _charityId, amount);
    }

    function closeIfExpired(uint _charityId) public {
        require(_charityId < allCharities.length, "Invalid charity ID");
        Charity storage charity = allCharities[_charityId];
        if (!charity.isCompleted && block.timestamp > charity.deadline) {
            charity.isCompleted = true;
            emit CharityClosed(msg.sender, _charityId);
        }
    }

    function getCharitiesByUser(address _user) external view returns (Charity[] memory) {
        return charityData[_user];
    }

    function getAllCharities() external view returns (Charity[] memory) {
        return allCharities;
    }
}