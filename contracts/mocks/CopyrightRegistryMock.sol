// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CopyrightRegistryMock is ERC721, Ownable, ReentrancyGuard {

    uint256 public totalSupply;

    struct Copyright {
        string baseUri;
        address admin;
        uint256[] shares;
        address[] authors; /// @dev array of authors addresses
    }

    /// @dev token id => copyright data
    mapping (bytes32 => Copyright) public copyrights;

    /// @dev tokenId => copyright id: copyright id is equal to tokenId, this time we use tokenId as a key
    mapping (uint256 => bytes32) public copyrightIds;

    /// @dev author address => token ids
    mapping (address => uint256[]) public authorTokens;

    constructor() ERC721("CopyrightRegistryMock", "CRM") {}

    function copyrightRegistry(
        bytes32 _copyrightId,
        string memory _baseUri, /// @dev base uri for token
        address _admin,
        uint256[] memory _shares,
        address[] memory _authors
    ) external nonReentrant {
        require(_authors.length == _shares.length, "PaymentSplitter: payees and shares length mismatch");
        require(_authors.length > 0, "PaymentSplitter: no payees");

        copyrights[_copyrightId] = Copyright({
            baseUri: _baseUri,
            admin: _admin,
            shares: _shares,
            authors: _authors
        });
        
        _minter(_copyrightId, _authors, _admin);
    }

    function setAuthors(
        bytes32 _copyrightId,
        uint256[] memory _shares,
        address[] memory _authors
    ) external nonReentrant onlyAdmin(_copyrightId) {
        require(_authors.length > 0, "PaymentSplitter: no payees");


        _minter(_copyrightId, _authors, copyrights[_copyrightId].admin);

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

    function _minter(
        bytes32 _copyrightId,
        address[] memory to,
        address _admin
    ) internal {
        for (uint256 i = 0; i < to.length; i++) {
            copyrightIds[totalSupply] = _copyrightId;
            _safeMint(_admin, totalSupply++);
            _safeTransfer(_admin, to[i], totalSupply, ""); /// @dev if to is admin address, ?            
        }
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "CopyrightRegistry: Nonexistent token");

        string memory baseUri = copyrights[copyrightIds[tokenId]].baseUri;
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

    /// @dev for frontend
    function getAdmin(bytes32 _copyrightId) public view returns (address) {
        return copyrights[_copyrightId].admin;
    }

    function getShares(bytes32 _copyrightId) public view returns (uint256[] memory) {
        return copyrights[_copyrightId].shares;
    }

    function getAuthors(bytes32 _copyrightId) public view returns (address[] memory) {
        return copyrights[_copyrightId].authors;
    }

    function getBaseUri(bytes32 _copyrightId) public view returns (string memory) {
        return copyrights[_copyrightId].baseUri;
    }

    function isAdmin(bytes32 _copyrightId) public view returns (bool) {
        return msg.sender == copyrights[_copyrightId].admin;
    }

    modifier onlyAdmin(bytes32 _copyrightId) {
        require(isAdmin(_copyrightId), "CopyrightRegistry: Only admin can call this function");
        _;
    }

    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }

}
