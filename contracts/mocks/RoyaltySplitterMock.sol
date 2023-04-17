// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @dev must change to interfaces
import "./CopyrightRegistryMock.sol";
import "./LicenseManagerMock.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RoyaltySplitterMock is Ownable{

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

    function splitter(
        bytes32 _copyrightId
    ) external {
        require(copyrightRegistry.copyrightIdExists(_copyrightId), "RoyaltySplitterMock: Copyright id does not exist");
        uint256 totalRevenue = copyrightRegistry.totalRevenue(_copyrightId);
        uint256 releasedRevenue = copyrightRegistry.releasedRevenue(_copyrightId);
        require(totalRevenue > releasedRevenue, "RoyaltySplitterMock: No revenue to split");

        uint256 releasableRevenue = totalRevenue - releasedRevenue;

        (address[] memory authors, uint256[] memory shares) = copyrightRegistry.getAuthors(_copyrightId);

        uint256 totalShares = 0;
        for (uint256 i = 0; i < shares.length; i++) {
            totalShares += shares[i];
        }

        for (uint256 i = 0; i < authors.length; i++) {
            payable(authors[i]).transfer(releasableRevenue * shares[i] / totalShares);
        }

        copyrightRegistry.incrementReleasedRevenue(_copyrightId, releasableRevenue);
    }

    // @dev modifier for only authors, but everyone can call split()
    // modifier onlyAutors(bytes32 _copyrightId) {
    //     (address[] memory authors,) = copyrightRegistry.getAuthors(_copyrightId);
    //     require();
    //     _;
    // }

    function setCopyrightRegistry(address _copyrightRegistryAddress) external onlyOwner {
        copyrightRegistry = CopyrightRegistryMock(_copyrightRegistryAddress);
    }

    function setLicenseManager(address _licenseManagerAddress) external onlyOwner {
        licenseManager = LicenseManagerMock(_licenseManagerAddress);
    }
    
}
