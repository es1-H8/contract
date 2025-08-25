pragma solidity ^0.8.23;

// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";
import "@openzeppelin/contracts/interfaces/IERC1967.sol";
import "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";

contract CustomProxy is TransparentUpgradeableProxy {
    constructor(address _logic, address initialOwner, bytes memory _data) 
        TransparentUpgradeableProxy(_logic, initialOwner, _data) {}
}