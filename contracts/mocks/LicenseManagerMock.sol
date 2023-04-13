// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./CopyrightRegistryMock.sol";

contract LicenseManagerMock is ERC721, Ownable {

    uint256 public totalSupply;

    string public expireUri;

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

    struct LicenseMetadata {
        // string name;
        // string description;
        // string image;
        // string externalUrl;
        uint256 issueDate;
    }

    /// @dev for license NFT
    /// @dev token id => license id
    mapping (uint256 => bytes32) public licenseIdsByTokenId;

    /// @dev for license NFT
    /// @dev license id => license data
    mapping (bytes32 => License) public licenses;

    mapping (uint256 => LicenseMetadata) public licenseMetadata;

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
            baseUri: _baseUri,
            copyrightId: _copyrightId
        });

        licenses[_licenseId] = license;
        licenseIdsByCopyrightId[_copyrightId].push(_licenseId);
    }

    /// @dev Issue license
    function issueLicense(
        bytes32 _copyrightId,
        bytes32 _licenseId
    ) external payable {
        require(copyrightRegistry.copyrightIdExists(_copyrightId), "LicenseManager: copyright id doesn't exist");
        require(licenseIdExists(_licenseId), "LicenseManager: license id doesn't exist");
        require(_canIssueLicense(_copyrightId, _licenseId), "LicenseManager: can't issue license");
        require(msg.value == licenses[_licenseId].price, "LicenseManager: wrong price");

        _safeMint(msg.sender, totalSupply);
        licenses[_licenseId].localSupply++;
        licenseIdsByTokenId[totalSupply] = _licenseId;
        // splitterAddress.transfer(msg.value);

        totalSupply++;
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

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {

        if (block.timestamp > licenses[licenseIdOf(tokenId)].duration + 
            
        ) {
            return expireUri;
        }
        
        return licenses[licenseIdOf(tokenId)].baseUri;
    }

    /// @dev Check if license can be issued
    function _canIssueLicense(
        bytes32 _copyrightId,
        bytes32 _licenseId
    ) internal view returns (bool) {
        License memory license = licenses[_copyrightId];
        return license.maxQuantity == 0 || license.localSupply < license.maxQuantity;
    }

    function generateLicenseId(
        uint256 _number,
        bytes32 _copyrightId
    ) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_number, _copyrightId));
    }

    function getCopyrightIdByLicenseId(
        bytes32 _licenseId
    ) external view returns (bytes32) {
        return licenses[_licenseId].copyrightId;
    }

    function licenseIdExists(
        bytes32 _licenseId
    ) public view returns (bool) {
        return licenses[_licenseId].copyrightId != bytes32(0);
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

    function licenseIdOf(
        uint256 _tokenId
    ) external view returns (bytes32) {
        return licenseIdsByTokenId[_tokenId];
    }

    /// @dev Only author can call this function
    modifier onlyAdmin(bytes32 _copyrightId) {
        require(copyrightRegistry.getAdmin(_copyrightId) == msg.sender, "LicenseManager: only admin");
        _;
    }

    function setCopyrightRegistryAddress(address _copyrightRegistryAddress) external onlyOwner {
        copyrightRegistry = CopyrightRegistryMock(_copyrightRegistryAddress);
    }

    function setExpireUri(string memory _expireUri) external onlyOwner {
        expireUri = _expireUri;
    }

}
