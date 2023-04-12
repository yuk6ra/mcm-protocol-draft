// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LicenseManagerMock is ERC721, Ownable {

    uint256 public totalSupply;


    constructor() ERC721("TreatyMinterMock", "TMM") {}

    struct License {
        bytes32 id;
        uint256 price;
        uint256 duration;
        string baseUri;
    }

    /// @dev copyright id => license
    mapping (uint256 => mapping(bytes32 => License)) public licenses;

    /// @dev Register license
    function licenseRegistry(
        uint256 _copyrightId,
        bytes32 _id,
        uint256 _price,
        uint256 _duration,
        string memory _baseUri
    ) external onlyAuthor(_copyrightId) {

        License memory license = License({
            id: _id,
            price: _price,
            duration: _duration,
            baseUri: _baseUri
        });

        licenses[_copyrightId][_id] = license;
    }

    /// @dev Issue license
    function issueLicense(
        uint256 _copyrightId,
        bytes32 _id
    ) external payable onlyAuthor(_copyrightId) {        
        require(msg.value == licenses[_copyrightId][_id].price, "LicenseManager: wrong price");

        _safeMint(msg.sender, totalSupply++);
    }

    /// @dev Only author can call this function
    modifier onlyAuthor(uint256 _copyrightId) {
        require(_copyrightId == 0x000000000);
        _;
    }

}
