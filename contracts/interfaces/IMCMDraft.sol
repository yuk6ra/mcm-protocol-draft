// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IMCMDraft {
    function getContractAddress()
        external
        view
        returns (
            address _copyrightRegistryAddress,
            address _licenseManagerAddress,
            address _royaltySplitterAddress
        );
}
