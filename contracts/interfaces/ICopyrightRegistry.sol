// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface ICopyrightRegistry {

    /// @param _baseUri base uri for token
    /// @param _admin admin address
    /// @param _shares array of shares for authors
    /// @param _authors array of authors addresses
    function registerCopyright(
        string memory _baseUri,
        address _admin,
        uint256[] memory _shares,
        address[] memory _authors
    ) external;

    /// @param _input input for generate id => tokenId ?
    /// @return bytes32 id generated from keccak256
    function generateCopyrightId(uint256 _input) external pure returns (bytes32);

    /// @dev ↓
    
}