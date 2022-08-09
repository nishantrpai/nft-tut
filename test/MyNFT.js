const MyNFT = artifacts.require("../contracts/MyNFT.sol");
const metadata = 

// Traditional Truffle test
contract("MyNFT", (accounts) => {
  it("Should initialize nft", async function () {
    //initalize
    let account = accounts[0];
    const nftcontract = await MyNFT.new();
    let currentBalance = await nftcontract.balanceOf(account);
    assert.equal(currentBalance, 0);

    await nftcontract.signCard("nishantpai");
    await nftcontract.signCard("warren");
    //check balance
    // mint nft
    await nftcontract.mintNFT(account, metadata);

    currentBalance = await nftcontract.balanceOf(account);

    assert.equal(currentBalance, 1);
  });
});
