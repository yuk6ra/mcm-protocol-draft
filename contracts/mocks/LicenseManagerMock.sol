// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/ILicenseManager.sol";
import "./CopyrightRegistryMock.sol";
import "./CustomPushProtocol.sol";

contract LicenseManagerMock is 
    ILicenseManager,
    ERC721,
    Ownable
{

    uint256 public totalSupply;

    string public expireUri;

    CopyrightRegistryMock public copyrightRegistry;

    CustomPushProtocol public pushProtocol;

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
        uint256 totalSupply; /// @dev local supply of licenses
        string baseUri; /// @dev base uri for token
        bytes32 copyrightId; /// @dev copyright id
    }

    struct LicenseMetadata {
        // string name;
        // string description;
        // string image;
        // string externalUrl;
        uint256 issueDate; /// @dev issue date in seconds
    }

    /// @dev for license NFT
    /// @dev token id => license id
    mapping (uint256 => bytes32) public licenseIdsByTokenId;

    /// @dev for license NFT
    /// @dev license id => license data
    mapping (bytes32 => License) public licenses;

    /// @dev license id => license metadata
    mapping (uint256 => LicenseMetadata) public licenseMetadata;

    /// @dev for Test, copyright id => license id => license data
    // mapping (bytes32 => mapping (bytes32 => License)) public licenses;

    /// @dev copyright id => license ids
    mapping (bytes32 => bytes32[]) public licenseIdsByCopyrightId;

    /// @dev for Test, license id => token ids
    // mapping (bytes32 => uint256[]) public tokenIdsByLicenseId;
    
    /// @dev if copyright id is in License struct, this mapping is not needed
    /// @dev license id => copyright id
    // mapping (bytes32 => bytes32) public copyrightIdsByLicenseId;

    /// @dev Register license
    function registerLicense(
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
            totalSupply: 0,
            baseUri: _baseUri,
            copyrightId: _copyrightId
        });

        licenses[_licenseId] = license;
        licenseIdsByCopyrightId[_copyrightId].push(_licenseId);
        copyrightRegistry.incrementLicenseSupply(_copyrightId);
    }

    /// @dev Issue license
    function issueLicense(
        bytes32 _copyrightId,
        bytes32 _licenseId
    ) external payable {
        require(copyrightRegistry.copyrightIdExists(_copyrightId), "LicenseManager: copyright id doesn't exist");
        require(licenseIdExists(_licenseId), "LicenseManager: license id doesn't exist");
        require(_canIssueLicense(_copyrightId), "LicenseManager: can't issue license");
        require(msg.value == licenses[_licenseId].price, "LicenseManager: wrong price");
        
        if (address(pushProtocol) != address(0)) {
            address[] memory authors = copyrightRegistry.getCopyright(_copyrightId).authors;
            pushProtocol.sendIssueNotification(authors);
        }

        _safeMint(msg.sender, totalSupply);
        licenseIdsByTokenId[totalSupply] = _licenseId;
        licenseMetadata[totalSupply].issueDate = block.timestamp;

        payable(splitterAddress).transfer(msg.value);

        copyrightRegistry.incrementTotalRevenue(_copyrightId, msg.value);
        licenses[_licenseId].totalSupply++;
        totalSupply++;
    }

    /// @dev for RoyaltySplitter
    function setRoyaltySplitter(
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

        if (block.timestamp > licenses[licenseIdOf(tokenId)].duration + licenseMetadata[tokenId].issueDate
            && licenses[licenseIdOf(tokenId)].duration != 0            
        ) {
            return expireUri;
        }
        
        return licenses[licenseIdOf(tokenId)].baseUri;
    }

    /// @dev Check if license can be issued
    function _canIssueLicense(
        bytes32 _copyrightId
    ) internal view returns (bool) {
        License memory license = licenses[_copyrightId];        

        return license.maxQuantity == 0 || license.totalSupply <= license.maxQuantity;
        // return license.maxQuantity == 0;
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

    function getLicense(
        bytes32 _licenseId
    ) external view returns (License memory) {
        return licenses[_licenseId];
    }

    function licenseIdOf(
        uint256 _tokenId
    ) public view returns (bytes32) {
        return licenseIdsByTokenId[_tokenId];
    }

    function getLicenseIdsByCopyrightId(bytes32 _copyrightId) external view returns (bytes32[] memory) {
        return licenseIdsByCopyrightId[_copyrightId];
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

    function setCustomPushContract(address _customPushContract) external onlyOwner {
        pushProtocol = CustomPushProtocol(_customPushContract);
    }

    function getRevenueByLicenseId(bytes32 _licenseId) external view returns (uint256) {
        return licenses[_licenseId].totalSupply * licenses[_licenseId].price;
    }

}
