// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVirtualPersona{
     function safeMint(address to, string memory uri) external returns(uint256);
}