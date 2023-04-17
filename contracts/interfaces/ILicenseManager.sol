// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface ILicenseManager {

    /// @param _copyrightId copyright id generated from keccak256
    /// @param _price price (wei) for license 
    /// @param _duration expiration date in seconds
    /// @param _maxQuantity max quantity of licenses, 0 - unlimited
    /// @param _baseUri base uri for license token
    function registerLicense(
        bytes32 _copyrightId,
        // bytes32 _licenseId,
        uint256 _price,
        uint256 _duration,
        uint256 _maxQuantity,
        string memory _baseUri
    ) external;


    /// @param _copyrightId copyright id generated from keccak256
    /// @param _licenseId license id generated from keccak256
    function issueLicense(
        bytes32 _copyrightId,
        bytes32 _licenseId
    ) external payable;

    /// @param _number number for generate id, tekitou
    /// @param _copyrightId copyright id generated from keccak256
    function generateLicenseId(
        uint256 _number,
        bytes32 _copyrightId
    ) external pure returns (bytes32);

}