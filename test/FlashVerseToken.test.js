const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("FlashVerseToken", function () {
  let token, owner, addr1, addr2;

  beforeEach(async () => {
    [owner, addr1, addr2] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("FlashVerseToken");
    token = await Token.deploy();
    await token.deployed();
  });

  it("should mint initial supply to deployer", async () => {
    const totalSupply = await token.totalSupply();
    expect(await token.balanceOf(owner.address)).to.equal(totalSupply);
  });

  it("should whitelist burner and allow burning", async () => {
    await token.setBurnerWhitelist(addr1.address, true);
    expect(await token.isBurnerWhitelisted(addr1.address)).to.be.true;

    await token.transfer(addr1.address, ethers.utils.parseEther("100"));
    const tokenFromAddr1 = token.connect(addr1);

    await expect(tokenFromAddr1.burn(ethers.utils.parseEther("50")))
      .to.emit(token, "TokensBurned")
      .withArgs(addr1.address, ethers.utils.parseEther("50"));

    expect(await token.balanceOf(addr1.address)).to.equal(
      ethers.utils.parseEther("50")
    );
  });

  it("should not allow burn from non-whitelisted address", async () => {
    await token.transfer(addr2.address, ethers.utils.parseEther("10"));
    const tokenFromAddr2 = token.connect(addr2);

    await expect(tokenFromAddr2.burn(ethers.utils.parseEther("1"))).to.be.revertedWith(
      "Not whitelisted to burn"
    );
  });
});
