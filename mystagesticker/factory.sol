// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./erc1155.sol";
import {ERC2981} from "./ERC2981.sol";
import {AccessControl} from "@openzeppelin/contracts@5.5.0/access/AccessControl.sol";


contract MyStageFactory is AccessControl{
    bytes32 public constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");
    // Stores deployed MyStage contract instances
    MyStage[] private deployedTokens;

    event MyStageDeployed(
        address indexed tokenAddress,
        address indexed defaultAdmin,
        address indexed secondaryAdmin,
        address royaltyReceiver,
        uint96 royaltyNumerator
    );

    constructor(address _defaultAdmin, address _secondaryDeployer) {
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        _grantRole(DEPLOYER_ROLE, _defaultAdmin);
        _grantRole(DEPLOYER_ROLE, _secondaryDeployer);

    }
    

    /// @notice Deploy a new MyStage contract and store it.
    function deployMyStage(
        string memory baseUri, // expects something like ipfs://baxw...w4/\{id\}.json , id will we replaced with the token id
        address defaultAdmin,
        address secondaryAdmin,
        address royaltyReceiver,
        uint96 royaltyNumerator
    ) external onlyRole(DEPLOYER_ROLE) returns (address tokenAddress) {
        MyStage newToken = new MyStage(
            baseUri,
            defaultAdmin,
            secondaryAdmin,
            royaltyReceiver,
            royaltyNumerator
        );

        tokenAddress = address(newToken);
        deployedTokens.push(newToken);

        emit MyStageDeployed(
            tokenAddress,
            defaultAdmin,
            secondaryAdmin,
            royaltyReceiver,
            royaltyNumerator
        );
    }

    function deployedTokenCount() external view returns (uint256) {
        return deployedTokens.length;
    }

    function deployedTokenAt(uint256 index) external view returns (address) {
        return address(deployedTokens[index]);
    }
}