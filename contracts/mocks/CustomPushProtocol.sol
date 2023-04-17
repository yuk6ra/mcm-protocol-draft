// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IPUSHCommInterface.sol";
import "./LicenseManagerMock.sol";

contract CustomPushProtocol is Ownable {

    LicenseManagerMock public licenseManagerMock;

    address public channel;
    IPUSHCommInterface public pushProtocol;

    bytes public identity;

    // function sendNotification
    function sendIssueNotification(
        address[] calldata toAddresses
    ) external {
        require(msg.sender == address(licenseManagerMock), "CustomPushProtocol: Only PUSHComm can call this function");
        for (uint256 i = 0; i < toAddresses.length; i++) {
            pushProtocol.sendNotification(channel, toAddresses[i], identity);
        }
    }

    function setChannel(address _channel) external onlyOwner {
        channel = _channel;
    }

    function setIdentity(bytes calldata _identity) external onlyOwner {
        identity = _identity;
    }

    function setPushProtocol(address _pushProtocolAddress) external onlyOwner {
        pushProtocol = IPUSHCommInterface(_pushProtocolAddress);
    }

    function setLicenseManagerMock(address _licenseManagerMockAddress) external onlyOwner {
        licenseManagerMock = LicenseManagerMock(_licenseManagerMockAddress);
    }
}