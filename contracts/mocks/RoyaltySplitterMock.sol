// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @dev must change to interfaces
import "./CopyrightRegistryMock.sol";
import "./LicenseManagerMock.sol";

contract RoyaltySplitterMock {

    CopyrightRegistryMock public copyrightRegistry;

    constructor(
        address _copyrightRegistryAddress
    ) {
        copyrightRegistry = CopyrightRegistryMock(_copyrightRegistryAddress);
    }

    receive() external payable {}

    function split() external payable {
        
    }

    /// @dev modifier for only authors, but everyone can call split()
    // modifier onlyAutors(bytes32 _copyrightId) {
    //     (address[] memory authors,) = copyrightRegistry.getAuthors(_copyrightId);
    //     require();
    //     _;
    // }    
    
}
