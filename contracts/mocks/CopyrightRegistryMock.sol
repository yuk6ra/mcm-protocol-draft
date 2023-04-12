// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CopyrightRegistryMock is ERC721, Ownable, ReentrancyGuard{

    uint256 public totalSupply;

    struct Copyright {
        string baseUri;
        uint256[] shares;
        address[] authors; /// @dev array of authors addresses
        address admin;
    }

    /// @dev tokenId => copyright id: copyright id is equal to tokenId, this time we use tokenId as a key
    // mapping (uint256 => bytes32) public copyrightIds;

    /// @dev 
    mapping (uint256 => Copyright) public copyrights;

    constructor() ERC721("Rights NFT", "CR") {}

    function copyrightRegistry(        
        string memory _baseUri, /// @dev base uri for token
        uint256[] memory _shares,
        address[] memory _authors,
        address _admin
    ) public {
        require(_authors.length == _shares.length, "PaymentSplitter: payees and shares length mismatch");
        require(_authors.length > 0, "PaymentSplitter: no payees");
        
        copyrights[totalSupply] = Copyright({
            baseUri: _baseUri,
            shares: _shares,
            authors: _authors,
            admin: _admin
        });

        _minter(_authors);
    }

    function setAuthors(
        uint256 _tokenId,
        uint256[] memory _shares,
        address[] memory _authors
    ) public onlyAdmin(_tokenId) {
        require(_authors.length > 0, "PaymentSplitter: no payees");

        copyrights[_tokenId].shares = _shares;
        copyrights[_tokenId].authors = _authors;

        

    }

    function _minter(
        address[] memory to
    ) internal{
        for (uint256 i = 0; i < to.length; i++) {
            _safeMint(to[i], totalSupply);
        }
        totalSupply++;        
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "CopyrightRegistry: Nonexistent token");

        string memory baseUri = copyrights[tokenId].baseUri;
        require(bytes(baseUri).length > 0, "CopyrightRegistry: Base URI is not set");

        /// @dev ""
        return baseUri;
    }

    function isAdmin(uint256 _tokenId) public view returns (bool) {
        return msg.sender == copyrights[_tokenId].admin;
    }

    modifier onlyAdmin(uint256 _tokenId) {
        require(isAdmin(_tokenId), "CopyrightRegistry: Only admin can call this function");
        _;
    }


    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }

}
