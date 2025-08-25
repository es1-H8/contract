/**
 *Submitted for verification at BscScan.com on 2025-08-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @dev Minimal version of OpenZeppelin's Proxy
abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _implementation() internal view virtual returns (address);

    fallback() external payable virtual {
        _delegate(_implementation());
    }

    receive() external payable virtual {
        _delegate(_implementation());
    }
}

abstract contract ERC1967Upgrade {
    bytes32 internal constant _IMPLEMENTATION_SLOT = 
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address impl) {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _setImplementation(address newImplementation) private {
        require(newImplementation.code.length > 0, "Not a contract");
        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, newImplementation)
        }
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        require(target.code.length > 0, "Target not contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        require(success, "Delegatecall failed");
        return returndata;
    }
}

contract TransparentUpgradeableProxy is Proxy, ERC1967Upgrade {
    bytes32 internal constant _ADMIN_SLOT = 
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    constructor(address _logic, address admin_, bytes memory _data) payable {
        require(_logic != address(0) && admin_ != address(0), "Invalid address");

        assembly {
            sstore(_ADMIN_SLOT, admin_)
        }

        _upgradeTo(_logic);

        if (_data.length > 0) {
            _functionDelegateCall(_logic, _data);
        }
    }

    function _implementation() internal view override returns (address) {
        return _getImplementation();
    }

    function _admin() internal view returns (address adm) {
        bytes32 slot = _ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }
}