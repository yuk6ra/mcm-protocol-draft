const { ethers } = require("hardhat");

const id = ethers.utils.solidityKeccak256(
    ["uint256", "bytes32"],
    ["1", "0x9faaf2a2acbef387565796dff70e992dc4474d774b03b04c352ca5ba329bcabe"]
)
console.log(id)