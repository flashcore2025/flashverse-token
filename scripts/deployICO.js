// scripts/deploy_ico.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const FVC_TOKEN_ADDRESS = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"; // Replace with actual deployed token address
  const INITIAL_PRICE = ethers.parseUnits("0.008", 18); // $0.008

  const ICO = await ethers.getContractFactory("ICOUpgradeable");
  const ico = await upgrades.deployProxy(ICO, [FVC_TOKEN_ADDRESS, INITIAL_PRICE], {
    initializer: "initialize",
    kind: "uups"
  });

  await ico.waitForDeployment();

  console.log("ICO Proxy deployed to:", await ico.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
