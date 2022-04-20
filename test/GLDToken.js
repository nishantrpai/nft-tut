const { assert, artifacts, contract, expect } = require("hardhat");
const Vault = artifacts.require("../contracts/NFTVault.sol");
const NFT = artifacts.require("../contracts/NFT.sol");

contract("NFT", function ([creator, other]) {
    contract("NFTVault", () => {
        const TOTAL_SUPPLY = 1000000;
        it("should create vault", async function () {
            //create a nft vault
            console.log('create a vault');
            this.vault = await Vault.new();
            assert.equal(await this.vault.getVaultBalance(), TOTAL_SUPPLY);
        });

        it("should create a nft token", async function () {

            //give creator a nft token
            console.log('create a nft token');
            this.nftcontract = await NFT.new();
            this.token = await this.nftcontract.mintNFT(creator, "ipfs://QmQc4SpF3tMQgP5CCxtoaFtJJTTT8h4CjdSN4X9iFMCxoF")

            //check if creator has that token
            assert.equal(this.token.logs[0].args.tokenId, 1);
        });

        it("should transfer a nft token", async function () {
            console.log('transfer nft token');
            
            //check vault balance
            assert.equal(await this.vault.getVaultBalance(), TOTAL_SUPPLY);
            assert.equal(await this.vault.getCurrentBalance(), 0);

            //check if owner has token
            assert.equal(await this.nftcontract.balanceOf(creator), 1);
            assert.equal(await this.nftcontract.balanceOf(this.vault.address), 0);


            //transfer nft token to vault
            const receipt = await this.nftcontract.safeTransferFrom(creator, this.vault.address, this.token.logs[0].args.tokenId);

            // check if vault has token
            assert.equal(await this.nftcontract.balanceOf(creator), 0);
            assert.equal(await this.nftcontract.balanceOf(this.vault.address), 1);

            //check if creator has erc20 tokens
            assert.equal(await this.vault.getVaultBalance(), TOTAL_SUPPLY - 100);
            assert.equal(await this.vault.getCurrentBalance(), 100);
        });
    })
})