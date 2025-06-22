const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying with address:", deployer.address);

  const Token = await ethers.getContractFactory("FlashVerseToken");
  const proxy = await upgrades.deployProxy(Token, [deployer.address], {
    initializer: "initialize",
  });

  await proxy.waitForDeployment();
  console.log("FlashVerseToken deployed to:", await proxy.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
