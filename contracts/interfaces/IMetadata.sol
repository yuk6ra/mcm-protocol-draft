// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IMetadata {
    
    function tokenMetadata(uint256 tokenId) external view returns (string memory);

}