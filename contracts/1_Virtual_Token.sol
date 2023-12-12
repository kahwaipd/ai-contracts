// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@5.0.0/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts@5.0.0/access/Ownable.sol";
import "@openzeppelin/contracts@5.0.0/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts@5.0.0/token/ERC20/extensions/ERC20Votes.sol";

/// @custom:security-contact hello@world.com
contract Virtual is ERC20, ERC20Burnable, Ownable, ERC20Permit, ERC20Votes {
    constructor(address initialOwner)
        ERC20("Virtual", "VTL")
        Ownable(initialOwner)
        ERC20Permit("Virtual")
    {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Votes)
    {
        super._update(from, to, value);
    }

    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}
