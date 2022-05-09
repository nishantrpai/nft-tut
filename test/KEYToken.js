const { assert, artifacts, contract, expect, ethers } = require("hardhat");

const Vault = artifacts.require("../contracts/NFTVault.sol");
const NFT = artifacts.require("../contracts/NFT.sol");

contract("NFT", function ([creator, other]) {
    contract("NFTVault", () => {
        const TOTAL_SUPPLY = 1000000;
        const TOKEN_AMOUNT = 100;

        it("should create vault", async function () {
            this.vault = await Vault.new();
            this.keyAddr = await this.vault.getTokenAddr();

            const keyArtifact = await artifacts.readArtifact("KEYToken");
            this.keys = await ethers.getContractAt(keyArtifact.abi, this.keyAddr, ethers.provider);

            assert.equal(await this.keys.totalSupply(), TOTAL_SUPPLY);

            assert.equal(await this.vault.getVaultBalance(), TOTAL_SUPPLY);
        });

        it("should create a nft token", async function () {

            //give creator a nft token
            this.nftcontract = await NFT.new();
            // this.nftcontract2 = await NFT.new();

            this.token = [];
            this.token.push(await this.nftcontract.mintNFT(creator, "ipfs://QmQc4SpF3tMQgP5CCxtoaFtJJTTT8h4CjdSN4X9iFMCxoF"));

            this.token2 = [];
            //check if creator has that token
            for (let i = 0; i < this.token.length; i++) {
                assert.equal(this.token[i].logs[0].args.tokenId, 1);
            }

        });

        it("should transfer erc20 for nft", async function () {
            //pre condition
            //check vault balance
            assert.equal(await this.vault.getVaultBalance(), TOTAL_SUPPLY);
            assert.equal(await this.vault.getCurrentBalance(), 0);

            //check if owner has token
            assert.equal(await this.nftcontract.balanceOf(creator), this.token.length);
            assert.equal(await this.nftcontract.balanceOf(this.vault.address), 0);

            //whitelist address to send, will fail otherwise
            await this.vault.setWhiteList(this.nftcontract.address, true);
            // await this.vault.setWhiteList(this.nftcontract2.address, true);

            //transfer nft token to vault
            for (let i = 0; i < this.token.length; i++) {
                await this.nftcontract.safeTransferFrom(creator, this.vault.address, this.token[i].logs[0].args.tokenId);
            }

            // let vaultbalance = await this.vault.getVaultBalance();
            // let currentbalance = await this.vault.getCurrentBalance();
            // console.log(vaultbalance.toString(10), currentbalance.toString(10), TOTAL_SUPPLY - (TOKEN_AMOUNT * (this.token.length + this.token2.length)), TOKEN_AMOUNT);

            //transfer nft token to vault
            // for (let i = 0; i < this.token2.length; i++) {
            //     await this.nftcontract2.safeTransferFrom(creator, this.vault.address, this.token2[i].logs[0].args.tokenId);
            // }
            //post condition

            // check if vault has token
            assert.equal(await this.nftcontract.balanceOf(creator), 0);
            assert.equal(await this.nftcontract.balanceOf(this.vault.address), this.token.length);

            // check if vault has token
            // assert.equal(await this.nftcontract2.balanceOf(creator), 0);
            // assert.equal(await this.nftcontract2.balanceOf(this.vault.address), this.token2.length);

            //check if creator has erc20 tokens
            assert.equal(await this.vault.getVaultBalance(), TOTAL_SUPPLY - (TOKEN_AMOUNT * (this.token.length + this.token2.length)));
            assert.equal(await this.vault.getCurrentBalance(), TOKEN_AMOUNT * (this.token.length + this.token2.length));
        });


        it("should send all nft tokens for erc20", async function () {

            //transfer erc20 from creator to vault
            // need owners approval
            for (let i = 0; i < (this.token.length + this.token2.length); i++) {
                const signer = await ethers.provider.getSigner(creator)
                const tx1 = await this.keys.connect(signer).approve(this.vault.address, TOKEN_AMOUNT);
                await tx1.wait();
                const tx2 = await this.keys.connect(signer).increaseAllowance(this.vault.address, TOKEN_AMOUNT);
                await tx2.wait();
                await this.vault.receiveToken(creator, TOKEN_AMOUNT);
            }

            //back to pre conditon
            assert.equal(await this.vault.getVaultBalance(), TOTAL_SUPPLY);
            assert.equal(await this.vault.getCurrentBalance(), 0);

            // //check if owner has token
            assert.equal(await this.nftcontract.balanceOf(creator), this.token.length);
            // assert.equal(await this.nftcontract2.balanceOf(creator), this.token2.length);
            assert.equal(await this.nftcontract.balanceOf(this.vault.address), 0);
            // assert.equal(await this.nftcontract2.balanceOf(this.vault.address), 0);
        });

    })
})
