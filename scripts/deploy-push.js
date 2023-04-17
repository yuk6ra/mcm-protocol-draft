const args = require("../args/args.js")

const deploy = async () => {  
    const contractFactory = await ethers.getContractFactory("CustomPushProtocol");

    const contract = await contractFactory.deploy();

    await contract.deployed();

    console.log("Contract Address: ", contract.address);
};

deploy();
