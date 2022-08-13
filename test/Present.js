
// Traditional Truffle test
contract("Present", (accounts) => {
  it("Should initialize nft", async function () {
    this.account = accounts[0];
    const Present = await ethers.getContractFactory("Present");
    this.nftcontract = await Present.deploy();

    // await expect(this.nftcontract.tokenURI(1))
    //   .to.be.revertedWith(`This isn't Jacks birthday`)
  });

  it("Should initialize sign NFTs", async function () {
    // console.log(await this.nftcontract.tokenURI(34));
    // const [nishu, jalil, warren, ian] = await ethers.getSigners();
    // await this.nftcontract.connect(nishu).signCard("nishu");
    // await this.nftcontract.connect(jalil).signCard("jalil");
    // await this.nftcontract.connect(warren).signCard("warren");
    // await this.nftcontract.connect(ian).signCard("ian");
    // console.log(await this.nftcontract.tokenURI(34));
  });
  
});
