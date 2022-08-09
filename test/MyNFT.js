const MyNFT = artifacts.require("../contracts/MyNFT.sol");
const metadata = require("./metadata.json");

// Traditional Truffle test
contract("MyNFT", (accounts) => {
  it("Should initialize nft", async function () {
    //initalize
    let account = accounts[0];
    const nftcontract = await MyNFT.new();
    let currentBalance = await nftcontract.balanceOf(account);
    assert.equal(currentBalance, 0);

    console.log(await nftcontract.signCard("nishantpai"));
    console.log(await nftcontract.signCard("warren"));
    console.log(await nftcontract.getSigners());
    //check balance
    // mint nft
    await nftcontract.mintNFT(account, metadata);

    currentBalance = await nftcontract.balanceOf(account);

    assert.equal(currentBalance, 1);
  });
});
