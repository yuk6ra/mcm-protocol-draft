// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TreatyMinterMock is ERC721, Ownable {
    uint256 public totalSupply;

    constructor() ERC721("TreatyMinterMock", "TMM") {}

    struct ContractParams {
        uint256 price;
        uint256 duration;
        uint256 localSupply; /// @dev 0 - unlimited
        string licenseUrl;
    }

    /// @dev registry number => contract params    
    mapping (uint256 => ContractParams[]) public contractParams;

    function treaty(uint licenseNumber,uint256 _registryNumber) public payable {
        require(contractParams[_registryNumber].length > 0, "TreatyMinterMock: contract params not found");
        require(msg.value >= contractParams[_registryNumber][licenseNumber].price, "TreatyMinterMock: not enough ether");
        _safeMint(msg.sender, totalSupply++);
    }

}
