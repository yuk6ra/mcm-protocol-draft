// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IRoyaltySplitter {

    function splitter(bytes32 _copyrightId) external;
}