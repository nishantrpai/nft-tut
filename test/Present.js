const Present = artifacts.require("../contracts/Present.sol");
const imageToBase64 = require("image-to-base64");
const base64json = require("base64json");
const metadata = {
  name: "Happy Birthday Jack",
  description: "Happy birthday Jack - vv",
  attributes: [{ trait_type: "Type", value: "Normal" }],
  image: "",
};

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
    await this.nftcontract.signCard("warren");
    await this.nftcontract.signCard("nishu");
    await this.nftcontract.signCard("nishu");
    await this.nftcontract.signCard("nishu");
    await this.nftcontract.signCard("nishu");
    await this.nftcontract.signCard("nishu");
    await this.nftcontract.signCard("nishu");
    await this.nftcontract.tokenURI();
  });

  // it("Should initialize mint NFT", async function () {
  //   await this.nftcontract.mintNFT(this.account, tokenURI);
  // });

  // it("Balance should be equal to 1", async function () {
  //   currentBalance = await this.nftcontract.balanceOf(this.account);
  //   assert.equal(currentBalance, 1);
  // });
});
