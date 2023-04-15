const { ethers } = require("hardhat");

const copyrightId = ethers.utils.solidityKeccak256(
    ["uint256"],
    [2]
)
console.log("Copyright ID: ", copyrightId);

const licenseId = ethers.utils.solidityKeccak256(
    ["uint256", "bytes32"],
    [0, copyrightId]
)
console.log("License ID: ", licenseId);