// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @dev must change to interfaces
import "./CopyrightRegistryMock.sol";
import "./LicenseManagerMock.sol";

contract RoyaltySplitterMock {

    CopyrightRegistryMock public copyrightRegistry;
    LicenseManagerMock public licenseManager;

    constructor(
        address _copyrightRegistryAddress,
        address _licenseManagerAddress
    ) {
        copyrightRegistry = CopyrightRegistryMock(_copyrightRegistryAddress);
        licenseManager = LicenseManagerMock(_licenseManagerAddress);
    }

    receive() external payable {}

    function split(
        bytes32 _copyrightId
    ) external payable {
        (address[] memory authors, uint256[] memory shares) = copyrightRegistry.getAuthors(_copyrightId);

        bytes32[] memory licenseIds = licenseManager.getLicenseIdsByCopyrightId(_copyrightId)

        uint256 totalShares = 0;
        for (uint256 i = 0; i < shares.length; i++) {
            totalShares += shares[i];
        }
        for (uint256 i = 0; i < authors.length; i++) {
            payable(authors[i]).transfer(msg.value * shares[i] / totalShares);
        }
    }

    /// @dev modifier for only authors, but everyone can call split()
    // modifier onlyAutors(bytes32 _copyrightId) {
    //     (address[] memory authors,) = copyrightRegistry.getAuthors(_copyrightId);
    //     require();
    //     _;
    // }    
    
}
