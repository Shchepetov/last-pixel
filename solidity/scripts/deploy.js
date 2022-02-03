const { ethers } = require("hardhat");

async function main() {

  const GameFactory = await ethers.getContractFactory("Factory");
  const factory = await GameFactory.deploy();

  await factory.deployed();

  console.log("GameFactory deployed to:", factory.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
