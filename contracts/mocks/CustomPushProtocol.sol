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

    function sendIssueNotification(
        address to
    ) external {
        require(to == address(licenseManagerMock), "CustomPushProtocol: Only PUSHComm can call this function");
        pushProtocol.sendNotification(channel, to, identity);
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