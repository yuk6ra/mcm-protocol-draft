// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CopyrightRegistryMock is ERC721, Ownable {

    uint256 public totalSupply;

    struct Copyright {
        string title;
        string externalUrl;
        string dataUrl; /// @dev music file url
        uint256 duration;
        address[] authorAddresses; /// @dev array of authors addresses
    }

    /// @dev registry number => contract params
    mapping (uint256 => Copyright[]) public copyrights;

    constructor() ERC721("Rights NFT", "CR") {}

    function registry(
        string memory _title,
        string memory _externalUrl,
        string memory _dataUrl,
        uint256 _duration,
        address[] memory _authorAddresses
    ) public {

        Copyright memory _copyright = Copyright({
            title: _title,
            externalUrl: _externalUrl,
            dataUrl: _dataUrl,
            duration: _duration,
            authorAddresses: _authorAddresses
        });

        copyrights[totalSupply].push(_copyright);

        _minter(msg.sender, totalSupply++);
    }

    function _minter(address to, uint256 tokenId) internal{
        _safeMint(to, tokenId);
    }

    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }

}
