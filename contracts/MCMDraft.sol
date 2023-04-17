// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IMCMDraft.sol";

contract MCMdraft is IMCMDraft, Ownable {
    address public copyrightRegistryAddress;
    address public licenseManagerAddress;
    address public royaltySplitterAddress;

    function setContractAddress(
        address _copyrightRegistryAddress,
        address _licenseManagerAddress,
        address _royaltySplitterAddress
    ) external onlyOwner {
        copyrightRegistryAddress = _copyrightRegistryAddress;
        licenseManagerAddress = _licenseManagerAddress;
        royaltySplitterAddress = _royaltySplitterAddress;
    }

    function getContractAddress()
        external
        view
        returns (
            address _copyrightRegistryAddress,
            address _licenseManagerAddress,
            address _royaltySplitterAddress
        )
    {
        return (
            copyrightRegistryAddress,
            licenseManagerAddress,
            royaltySplitterAddress
        );
    }
}
