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
        string baseUri;
    }

    /// @dev copyright id => license
    mapping (bytes32 => License[]) public licenses;

    function licenseRegistry(
        bytes32 _copyrightId,
        bytes32 _id,
        uint256 _price,
        string memory _baseUri
    ) public onlyAuthor(_copyrightId) {

        License memory license = License({
            id: _id,
            price: _price,
            baseUri: _baseUri
        });

        licenses[_copyrightId].push(license);
    }

    /// @dev Only author can call this function
    modifier onlyAuthor(bytes32 _copyrightId) {
        require(_copyrightId == 0x000000000);
        _;
    }

}
