// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Counter {
    uint256 private count;
    
    event Incremented(uint256 amount);
    
    constructor() {
        count = 0;
    }
    
    function getCount() public view returns (uint256) {
        return count;
    }
    
    function increment() public {
        count += 1;
        emit Incremented(1);
    }
    
    function incrementBy(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        count += amount;
        emit Incremented(amount);
    }
}
