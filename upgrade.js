const { ethers, upgrades } = require("hardhat");

async function main() {
  const proxyAddress = "0x..."; // Existing proxy address
  const TokenV2 = await ethers.getContractFactory("FlashVerseTokenV2");
  const upgraded = await upgrades.upgradeProxy(proxyAddress, TokenV2);

  console.log("Upgraded to:", await upgraded.getAddress());
}

main();
