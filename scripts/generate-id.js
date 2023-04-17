const { ethers } = require("hardhat");


for (let i = 0; i < 10; i++) {
    console.log("=====", i, "=====")

    let copyrightId = ethers.utils.solidityKeccak256(
        ["uint256"],
        [i]
    )
    console.log("Copyright ID: ", copyrightId);
    console.log("baseURI:", `https://metadata.prtcl.xyz/metadata/copyrights/${i}.json`, "\n")

    for (let j = 0; j < 5; j++) {    
        let licenseId = ethers.utils.solidityKeccak256(
            ["uint256", "bytes32"],
            [j, copyrightId]
        )
        console.log(j,"License ID: ", licenseId);
        console.log("baseURI:", `https://metadata.prtcl.xyz/metadata/licenses/copyright-${i}-license-${j}.json`, "\n")
    }
}
