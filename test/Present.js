const Present = artifacts.require("../contracts/Present.sol");

// Traditional Truffle test
contract("Present", (accounts) => {
  it("Should initialize nft", async function () {
    this.account = accounts[0];
    this.nftcontract = await Present.new();
    let currentBalance = await this.nftcontract.balanceOf(this.account);
    assert.equal(currentBalance, 0);
  });

  it("Should initialize sign NFTs", async function () {
    await this.nftcontract.signCard("nishu");
  });
  
  it("Should initialize mint NFT", async function () {
    await this.nftcontract.mintNFT(this.account);
    // await this.nftcontract.mintNFT(this.account);
    // await this.nftcontract.signCard("nishu".toUpperCase());

    // let currentBalance = await this.nftcontract.balanceOf(this.account);
    // assert.equal(currentBalance, 1);
  });
});
