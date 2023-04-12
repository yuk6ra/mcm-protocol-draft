// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./CopyrightRegistryMock.sol";

contract LicenseManagerMock is ERC721, Ownable {

    uint256 public totalSupply;

    CopyrightRegistryMock public copyrightRegistry;

    constructor(
        address _copyrightRegistryAddress
    ) ERC721("TreatyMinterMock", "TMM") {
        copyrightRegistry = CopyrightRegistryMock(_copyrightRegistryAddress);        
    }

    struct License {
        bytes32 id; /// @dev license id
        uint256 price; /// @dev price in wei
        uint256 duration; /// @dev duration in seconds
        uint256 maxQuantity; /// @dev max quantity of licenses, 0 - unlimited
        uint256 localSupply; /// @dev local supply of licenses
        string baseUri; /// @dev base uri for token
    }

    /// @dev copyright id => license id => license data
    mapping (bytes32 => mapping (bytes32 => License)) public licenses;

    /// @dev Register license
    function licenseRegistry(
        bytes32 _copyrightId,
        bytes32 _licenseId,
        uint256 _price,
        uint256 _duration,
        uint256 _maxQuantity,
        string memory _baseUri
    ) external onlyAdmin(_copyrightId) {

        License memory license = License({
            id: _licenseId,
            price: _price,
            duration: _duration,
            maxQuantity: _maxQuantity,
            localSupply: 0,
            baseUri: _baseUri
        });

        licenses[_copyrightId][_licenseId] = license;
    }

    /// @dev Issue license
    function issueLicense(
        bytes32 _copyrightId,
        bytes32 _licenseId
    ) external payable {
        require(msg.value == licenses[_copyrightId][_licenseId].price, "LicenseManager: wrong price");
        require(_canIssueLicense(_copyrightId, _licenseId), "LicenseManager: can't issue license");

        _safeMint(msg.sender, totalSupply++);
        licenses[_copyrightId][_licenseId].localSupply++;
    }

    function _canIssueLicense(
        bytes32 _copyrightId,
        bytes32 _licenseId
    ) internal view returns (bool) {
        License memory license = licenses[_copyrightId][_licenseId];
        return license.maxQuantity == 0 || license.localSupply < license.maxQuantity;
    }

    /// @dev Only author can call this function
    modifier onlyAdmin(bytes32 _copyrightId) {
        require(copyrightRegistry.getAdmin(_copyrightId) == msg.sender, "LicenseManager: only admin");
        _;
    }

}
