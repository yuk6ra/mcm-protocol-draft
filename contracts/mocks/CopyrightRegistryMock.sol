// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../interfaces/ICopyrightRegistry.sol";
// import "../interfaces/ILicenseMetadata.sol";

contract CopyrightRegistryMock is 
    ICopyrightRegistry,
    ERC721,
    Ownable,
    ReentrancyGuard   
{

    uint256 public totalSupply; /// @dev total supply of copyrights NFT
    uint256 public copyrightSupply; /// @dev total supply of copyrights
    address public licenseManager;

    // ILicenseMetadata public licenseMetadata;

    struct Copyright {
        uint256 registrationDate;
        uint256 licenseSupply; /// @dev total supply of licenses
        string baseUri;
        address admin;
        uint256[] shares;
        address[] authors; /// @dev array of authors addresses
    }

    /// @dev copyright id => copyright data
    mapping (bytes32 => Copyright) public copyrights;

    /// @dev tokenId => copyright id: copyright id is equal to tokenId, this time we use tokenId as a key
    mapping (uint256 => bytes32) public copyrightIdsByTokenId;

    /// @dev author address => token ids
    // mapping (address => uint256[]) public authorTokens;

    constructor(
        address _licenseManagerAddress
    ) ERC721("CopyrightRegistryMock", "CRM") {
        licenseManager = _licenseManagerAddress;
    }

    function registerCopyright(
        string memory _baseUri, /// @dev base uri for token
        address _admin,
        uint256[] memory _shares,
        address[] memory _authors
    ) external nonReentrant {
        require(_authors.length == _shares.length, "PaymentSplitter: payees and shares length mismatch");
        require(_authors.length > 0, "PaymentSplitter: no payees");
        require(_admin != address(0), ": admin is the zero address");
        require(bytes(_baseUri).length > 0, "CopyrightRegistry: Base URI is not set");

        bytes32 copyrightId = generateCopyrightId(copyrightSupply);

        copyrights[copyrightId] = Copyright({
            registrationDate: block.timestamp,
            licenseSupply: 0,
            baseUri: _baseUri,
            admin: _admin,
            shares: _shares,
            authors: _authors
        });
        
        _minter(copyrightId, _authors);
        // _minter(copyrightId, _authors, _admin);
    }


    function updateAuthors(
        bytes32 _copyrightId,
        uint256[] memory _shares,
        address[] memory _authors
    ) external onlyAdmin(_copyrightId) {
        require(_authors.length > 0, "PaymentSplitter: no payees");

        _minter(_copyrightId, _authors);
        // _minter(_copyrightId, _authors, copyrights[_copyrightId].admin);

        /// @dev delete authors, burn tokens
        address[] memory deletedAuthors = _getDeletedAuthors(_copyrightId, _authors);
        for (uint256 i = 0; i < deletedAuthors.length; i++) {
            if (deletedAuthors[i] != address(0)) {
                // _burn();
            }
        }

        copyrights[_copyrightId].shares = _shares;
        copyrights[_copyrightId].authors = _authors;
    }

    function setAdmin(
        bytes32 _copyrightId,
        address _admin
    ) external onlyAdmin(_copyrightId) {
        require(_admin != msg.sender, ": admin is the sender address");
        require(_admin != address(0), ": admin is the zero address");
        copyrights[_copyrightId].admin = _admin;
    }

    function setBaseUri(
        bytes32 _copyrightId,
        string memory _baseUri
    ) external onlyAdmin(_copyrightId) {
        require(bytes(_baseUri).length > 0, "CopyrightRegistry: Base URI is not set");
        copyrights[_copyrightId].baseUri = _baseUri;
    }

    function _minter(
        bytes32 _copyrightId,
        address[] memory to
        // address _admin
    ) internal {
        for (uint256 i = 0; i < to.length; i++) {
            copyrightIdsByTokenId[totalSupply] = _copyrightId;
            _safeMint(to[i], totalSupply++);
            // _safeTransfer(_admin, to[i], totalSupply, ""); /// @dev if to is admin address, ?            
        }

        copyrightSupply++;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "CopyrightRegistry: Nonexistent token");

        string memory baseUri = copyrights[copyrightIdOf(tokenId)].baseUri;
        require(bytes(baseUri).length > 0, "CopyrightRegistry: Base URI is not set");

        /// @dev ""
        return baseUri;
    }

    function _getDeletedAuthors(bytes32 _copyrightId, address[] memory _authors)
        internal
        view
        returns (address[] memory)
    {
        address[] memory prevAuthors = copyrights[_copyrightId].authors;
        address[] memory deletedAuthors = new address[](prevAuthors.length);

        uint256 deletedAuthorsIndex = 0;
        bool isMatched;

        for (uint256 i = 0; i < _authors.length; i++) {
            isMatched = false;

            for (uint256 j = 0; j < prevAuthors.length; j++) {
                if (_authors[i] == prevAuthors[j]) {
                    isMatched = true;
                    break;
                }
            }

            if (!isMatched) {
                deletedAuthors[deletedAuthorsIndex] = _authors[i];
                deletedAuthorsIndex++;
            }
        }

        return deletedAuthors;
    }

    function generateCopyrightId(uint256 _input) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_input));
    }

    /// @dev set functions
    function setLicenseMetadata(
        bytes32 _copyrightId,
        string memory _baseUri
    ) external onlyOwner {

    }

    function incrementLicenseSupply(bytes32 _copyrightId) external onlyLicenseManager {
        copyrights[_copyrightId].licenseSupply++;
    }

    /// @dev for frontend
    function getAdmin(bytes32 _copyrightId) public view returns (address) {
        return copyrights[_copyrightId].admin;
    }

    function getAuthors(bytes32 _copyrightId) public view returns (address[] memory authors, uint256[] memory shares) {
        Copyright memory c = copyrights[_copyrightId];
        return (c.authors, c.shares);
    }

    function getBaseUri(bytes32 _copyrightId) public view returns (string memory) {
        return copyrights[_copyrightId].baseUri;
    }

    function getCopyright(bytes32 _copyrightId) public view returns (Copyright memory) {
        return copyrights[_copyrightId];
    }

    function copyrightIdOf(uint256 _tokenId) public view returns (bytes32) {
        return copyrightIdsByTokenId[_tokenId];
    }

    function copyrightIdExists(bytes32 _copyrightId) public view returns (bool) {
        return copyrights[_copyrightId].registrationDate > 0;
    }

    function isAdmin(bytes32 _copyrightId) public view returns (bool) {
        return msg.sender == copyrights[_copyrightId].admin;
    }

    modifier onlyAdmin(bytes32 _copyrightId) {
        require(isAdmin(_copyrightId), "CopyrightRegistry: Only admin can call this function");
        _;
    }

    modifier onlyLicenseManager() {
        require(msg.sender == address(licenseManager), "CopyrightRegistry: Only license manager contract can call this function");
        _;
    }

    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }

}
