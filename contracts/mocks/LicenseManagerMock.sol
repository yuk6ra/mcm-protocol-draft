// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./CopyrightRegistryMock.sol";

contract LicenseManagerMock is ERC721, Ownable {

    uint256 public totalSupply;

    CopyrightRegistryMock public copyrightRegistry;

    address public splitterAddress;

    constructor(
        address _copyrightRegistryAddress
    ) ERC721("LicenseManagerMock", "LMM") {
        copyrightRegistry = CopyrightRegistryMock(_copyrightRegistryAddress);        
    }

    struct License {
        uint256 price; /// @dev price in wei
        uint256 duration; /// @dev duration in seconds
        uint256 maxQuantity; /// @dev max quantity of licenses, 0 - unlimited
        uint256 localSupply; /// @dev local supply of licenses
        string baseUri; /// @dev base uri for token
        bytes32 copyrightId; /// @dev copyright id
    }

    /// @dev for license NFT
    /// @dev token id => license id
    mapping (uint256 => bytes32) public licenseIds;

    /// @dev for license NFT
    /// @dev license id => license data
    mapping (bytes32 => License) public licenses;

    /// @dev for Test, copyright id => license id => license data
    // mapping (bytes32 => mapping (bytes32 => License)) public licenses;

    /// @dev copyright id => license ids
    mapping (bytes32 => bytes32[]) public licenseIdsByCopyrightId;

    /// @dev if copyright id is in License struct, this mapping is not needed
    /// @dev license id => copyright id
    // mapping (bytes32 => bytes32) public copyrightIdsByLicenseId;

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
            price: _price,
            duration: _duration,
            maxQuantity: _maxQuantity,
            localSupply: 0,
            baseUri: _baseUri
        });

        licenses[_licenseId] = license;
        licenseIdsByCopyrightId[_copyrightId].push(_licenseId);
    }

    /// @dev Issue license
    function issueLicense(
        bytes32 _copyrightId,
        bytes32 _licenseId
    ) external payable {
        require(_canIssueLicense(_copyrightId, _licenseId), "LicenseManager: can't issue license");
        require(msg.value == licenses[_copyrightId][_licenseId].price, "LicenseManager: wrong price");

        _safeMint(msg.sender, totalSupply++);
        licenses[_copyrightId][_licenseId].localSupply++;
        splitterAddress.transfer(msg.value);
    }

    /// @dev for RoyaltySplitter
    function setSplitterAddress(
        address _splitterAddress
    ) external onlyOwner {
        require(_splitterAddress != address(0), "LicenseManager: splitter address is the zero address");
        splitterAddress = _splitterAddress;
    }        

    // function deleteLicense(
    //     bytes32 _licenseId
    // ) external onlyAdmin(licenses[_licenseId].copyrightId) {
    // }

    // function tokenURI(
    //     uint256 tokenId
    // ) public view override returns (string memory) {
    //     return licenses[licenseIds[_tokenId]].baseUri;
    // }

    /// @dev Check if license can be issued
    function _canIssueLicense(
        bytes32 _copyrightId,
        bytes32 _licenseId
    ) internal view returns (bool) {
        License memory license = licenses[_copyrightId][_licenseId];
        return license.maxQuantity == 0 || license.localSupply < license.maxQuantity;
    }

    function getCopyrightIdByLicenseId(
        bytes32 _licenseId
    ) external view returns (bytes32) {
        return licenses[_licenseId].copyrightId;
    }

    function getAllLicenses() public view returns (License[] memory) {
        uint256 numLicenses = 0;
        bytes32[] memory keys = new bytes32[](licenseIds.length);

        for (uint256 i = 0; i < licenseIds.length; i++) {
            bytes32 key = licenseIds[i];
            if (licenses[key].registrationDate != 0) {
                keys[numLicenses] = key;
                numLicenses++;
            }
        }

        License[] memory allLicenses = new License[](numLicenses);

        for (uint256 i = 0; i < numLicenses; i++) {
            bytes32 key = keys[i];
            allLicenses[i] = licenses[key];
        }

        return allLicenses;
    }

    // function _minter(
    //     bytes32 _copyrightId,
    //     address[] memory _authors,
    //     address _admin
    // ) internal {
    //     uint256 tokenId = totalSupply++;
    //     _safeMint(_admin, tokenId);
        
    // }

    // function getLicenseId(
    //     bytes32 _copyrightId,
    //     bytes32 _licenseId
    // ) external view returns (License memory) {
    //     return 
    // }

    /// @dev Only author can call this function
    modifier onlyAdmin(bytes32 _copyrightId) {
        require(copyrightRegistry.getAdmin(_copyrightId) == msg.sender, "LicenseManager: only admin");
        _;
    }

    function setCopyrightRegistry(address _copyrightRegistryAddress) external onlyOwner {
        copyrightRegistry = CopyrightRegistryMock(_copyrightRegistryAddress);
    }

}
