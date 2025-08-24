// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title Counter
 * @author Smart Contract Developer
 * @notice A simple counter contract for demonstration purposes
 * @dev This contract demonstrates basic Solidity patterns and is used for CI/CD testing
 */
contract Counter {
    /// @notice The current counter value
    uint256 public count;
    
    /// @notice Event emitted when the counter is incremented
    /// @param by The amount by which the counter was incremented
    event Incremented(uint256 by);
    
    /// @notice Mapping to store user balances
    mapping(address => uint256) public balances;
    
    /// @notice Increment the counter by 1
    function increment() public {
        count++;
        emit Incremented(1);
    }
    
    /// @notice Increment the counter by a specific amount
    /// @param amount The amount to increment by
    function incrementBy(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        count += amount;
        emit Incremented(amount);
    }
    
    /// @notice Get the current counter value
    /// @return The current count
    function getCount() public view returns (uint256) {
        return count;
    }
    
    // VULNERABILITY: Classic reentrancy attack vector
    // This function allows external calls before updating state
    function withdraw() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");
        
        // VULNERABILITY: External call before state update
        // This allows reentrancy attacks - attackers can call withdraw() multiple times
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        // State update happens after external call - VULNERABLE!
        balances[msg.sender] = 0;
    }
    
    // Function to add balance (for testing the vulnerability)
    function addBalance() public payable {
        balances[msg.sender] += msg.value;
    }
    
    // Function to get contract balance
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // ADDITIONAL VULNERABILITIES TO ENSURE >10 WARNINGS
    
    // VULNERABILITY: Unchecked external call
    function unsafeExternalCall(address target) public {
        (bool success,) = target.call(""); // Missing success check
        // success variable is unused - will trigger warning
    }
    
    // VULNERABILITY: Block timestamp dependency
    function timeBasedFunction() public view returns (bool) {
        return block.timestamp > 1000000000; // Relies on block timestamp
    }
    
    // VULNERABILITY: Block number dependency
    function blockNumberFunction() public view returns (bool) {
        return block.number % 10 == 0; // Relies on block number
    }
    
    // VULNERABILITY: tx.origin usage
    function checkOrigin() public view returns (bool) {
        return tx.origin == msg.sender; // Dangerous tx.origin usage
    }
    
    // VULNERABILITY: Low level call without proper checks
    function lowLevelCall(address target) public {
        assembly {
            let result := call(gas(), target, 0, 0, 0, 0, 0)
        }
    }
    
    // VULNERABILITY: Unchecked math operations
    function uncheckedMath(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 c = a + b; // No overflow check
        return c;
    }
    
    // VULNERABILITY: Unchecked external call return value
    function uninitializedStorage() public {
        // This will trigger warnings about unchecked external calls
        address(0).call(""); // Call to zero address without success check
    }
    
    // VULNERABILITY: Function visibility not specified
    function noVisibility() public {
        // Function without visibility modifier
    }
    
    // VULNERABILITY: State variable visibility not specified
    uint256 public noVisibilityVar;
    
    // VULNERABILITY: Function parameter name not specified (but fixed for compilation)
    function noParamName(uint256 param) public pure returns (uint256) {
        return param; // Using parameter to avoid unused variable warning
    }
    
    // VULNERABILITY: Event parameter name not specified
    event NoParamName(uint256 param);
    
    // VULNERABILITY: Contract name doesn't match filename
    // This will trigger naming convention warnings
    
    // VULNERABILITY: Missing NatSpec documentation
    function noNatSpec() public {
        // Function without proper documentation
    }
    
    // VULNERABILITY: Complex fallback function
    fallback() external {
        // Complex fallback function
        if (msg.sender == address(0)) {
            revert();
        }
    }
    
    // VULNERABILITY: Receive function with logic
    receive() external payable {
        // Receive function with complex logic
        if (msg.value > 0) {
            balances[msg.sender] += msg.value;
        }
    }
}
