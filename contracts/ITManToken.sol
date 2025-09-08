// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @custom:security-contact dung@productsway.com
contract ITManToken is
	Initializable,
	ERC20Upgradeable,
	OwnableUpgradeable,
	ERC20PermitUpgradeable,
	UUPSUpgradeable
{
	/// @custom:oz-upgrades-unsafe-allow constructor
	constructor() {
		_disableInitializers();
	}

	function initialize(address initialOwner) public initializer {
		__ERC20_init("ITManToken", "ITM");
		__Ownable_init();
		__ERC20Permit_init("ITManToken");
		__UUPSUpgradeable_init();
		_mint(msg.sender, 1000000 * 10 ** decimals());
	}


	function mint(address to, uint256 amount) public onlyOwner {
		_mint(to, amount);
	}

	function _authorizeUpgrade(address newImplementation)
		internal
		override
		onlyOwner
	{}

	// The following functions are overrides required by Solidity.

}