// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IVirtualPersona.sol";

contract VirtualFactory is AccessControl {
    struct VirtualInfo {
        address virtualAddress;
        address stakingAddress;
    }

    struct VirtualRequest {
        address initiator;
        uint256 stakedAmount;
        string uri;
        uint256 tokenId;
    }

    mapping(uint256 => VirtualInfo) public virtualInfos;

    mapping(uint256 => VirtualRequest) public virtualRequests;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    uint256 public initialStakeAmount;

    Governor public dao;

    IVirtualPersona public virtualPersona;

    IERC20 public token;

    uint256 private _nextRequestId;

    // Constructor to initialize the contract with the default admin role and tokenAddress
    constructor(
        address defaultAdmin,
        address tokenAddress,
        uint256 stakeAmount,
        address payable daoAddress,
        address nftAddress
    ) {
        _grantRole(ADMIN_ROLE, defaultAdmin);
        token = IERC20(tokenAddress);
        initialStakeAmount = stakeAmount;
        dao = Governor(daoAddress);
        virtualPersona = IVirtualPersona(nftAddress);
    }

    // Function to set the virtual information for a user
    function setVirtualInfo(
        uint256 tokenId,
        address virtualAddress,
        address stakingAddress
    ) public {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "Only admins can modify virtual information"
        );
        VirtualInfo memory newVirtualInfo = VirtualInfo({
            virtualAddress: virtualAddress,
            stakingAddress: stakingAddress
        });

        virtualInfos[tokenId] = newVirtualInfo;
    }

    // Function to get the virtual information for a user
    function getVirtualInfo(uint256 tokenId)
        public
        view
        returns (address, address)
    {
        VirtualInfo memory info = virtualInfos[tokenId];
        return (info.virtualAddress, info.stakingAddress);
    }

    // Function to update the token address (only accessible by admins)
    function setToken(address newTokenAddress) public {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "Only admins can update tokenAddress"
        );
        token = IERC20(newTokenAddress);
    }

    // Function to update the initial stake amount (only accessible by admins)
    function setInitialStake(uint256 newInitialStakeAmount) public {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "Only admins can update initial stake amount"
        );
        initialStakeAmount = newInitialStakeAmount;
    }

    // Function to update the DAO address (only accessible by admins)
    function setDaoAddress(address payable newDaoAddress) public {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "Only admins can update DAO address"
        );
        dao = Governor(newDaoAddress);
    }

    // Function to create new virtual proposal
    function proposeVirtual(string memory uri) public returns(uint256) {
        require(token.balanceOf(msg.sender) >= initialStakeAmount, "Insufficient balance");

        // TODO: call transferFrom to transfer stake amount from sender

        uint256 requestId = ++_nextRequestId;
        VirtualRequest memory req = VirtualRequest({
            initiator: msg.sender,
            stakedAmount: initialStakeAmount,
            uri: uri,
            tokenId: 0
        });

        virtualRequests[requestId] = req;
        return requestId;
    }

    function createVirtual(uint256 requestId) public {
        VirtualRequest storage req = virtualRequests[requestId];
        require(req.tokenId == 0, "Virtual already created");
        require(req.initiator != address(0), "Invalid request");

        uint256 tokenId = virtualPersona.safeMint(address(dao), req.uri);
        req.tokenId = tokenId;

        // TODO:
        // 1. Call createAccount on TBA
        // 2. Clone Staking
    }
}
