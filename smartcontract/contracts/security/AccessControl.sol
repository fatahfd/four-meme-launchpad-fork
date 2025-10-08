// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title AccessControl
 * @dev Enhanced access control with role-based permissions
 */
contract AccessControl is AccessControl {
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    /**
     * @dev Grant moderator role
     * @param account Account to grant role to
     */
    function grantModeratorRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(MODERATOR_ROLE, account);
    }
    
    /**
     * @dev Revoke moderator role
     * @param account Account to revoke role from
     */
    function revokeModeratorRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(MODERATOR_ROLE, account);
    }
    
    /**
     * @dev Grant operator role
     * @param account Account to grant role to
     */
    function grantOperatorRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(OPERATOR_ROLE, account);
    }
    
    /**
     * @dev Revoke operator role
     * @param account Account to revoke role from
     */
    function revokeOperatorRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(OPERATOR_ROLE, account);
    }
}
