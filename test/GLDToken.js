const { assert, artifacts, contract, expect, ethers } = require("hardhat");

const Vault = artifacts.require("../contracts/NFTVault.sol");
const NFT = artifacts.require("../contracts/NFT.sol");

contract("NFT", function ([creator, other]) {
    contract("NFTVault", () => {
        const TOTAL_SUPPLY = 1000000;
        const TOKEN_AMOUNT = 100;

        it("should create vault", async function () {
            this.vault = await Vault.new();
            this.goldAddr = await this.vault.getTokenAddr();

            console.log()

            console.log(creator);
            const goldArtifact = await artifacts.readArtifact("GLDToken");
            this.gold = await ethers.getContractAt(goldArtifact.abi, this.goldAddr, ethers.provider);

            assert.equal(await this.gold.totalSupply(), TOTAL_SUPPLY);

            assert.equal(await this.vault.getVaultBalance(), TOTAL_SUPPLY);
        });

        it("should create a nft token", async function () {

            //give creator a nft token
            this.nftcontract = await NFT.new();
            this.token = await this.nftcontract.mintNFT(creator, "ipfs://QmQc4SpF3tMQgP5CCxtoaFtJJTTT8h4CjdSN4X9iFMCxoF")

            //check if creator has that token
            assert.equal(this.token.logs[0].args.tokenId, 1);
        });

        it("should transfer erc20 for nft", async function () {
            //pre condition

            //check vault balance
            assert.equal(await this.vault.getVaultBalance(), TOTAL_SUPPLY);
            assert.equal(await this.vault.getCurrentBalance(), 0);

            //check if owner has token
            assert.equal(await this.nftcontract.balanceOf(creator), 1);
            assert.equal(await this.nftcontract.balanceOf(this.vault.address), 0);

            //whitelist address to send, will fail otherwise
            await this.vault.setWhiteList(this.nftcontract.address, true);

            //transfer nft token to vault
            const receipt = await this.nftcontract.safeTransferFrom(creator, this.vault.address, this.token.logs[0].args.tokenId);

            //post condition

            // check if vault has token
            assert.equal(await this.nftcontract.balanceOf(creator), 0);
            assert.equal(await this.nftcontract.balanceOf(this.vault.address), 1);

            //check if creator has erc20 tokens
            assert.equal(await this.vault.getVaultBalance(), TOTAL_SUPPLY - 100);
            assert.equal(await this.vault.getCurrentBalance(), 100);
        });


        it("should send nft token for erc20", async function () {
            let vaultbalance = await this.vault.getVaultBalance();
            let currentbalance = await this.vault.getCurrentBalance();
            // let totalSupply = await this.gold.totalSupply();
            console.log(vaultbalance.toString(10));
            console.log(currentbalance.toString(10));
            // console.log(totalSupply.toString(10));



            //transfer erc20 from creator to vault
            // need owners approval
            // await this.token.approve(this.vault.address, 10, { from: creator });
            // let allowance = await this.gold.allowance(creator, this.vault.address);
            // console.log(allowance.toString(10));
            const signer = await ethers.provider.getSigner(creator)
            const tx1 = await this.gold.connect(signer).approve(this.vault.address, TOKEN_AMOUNT);
            await tx1.wait();
            const tx2 = await this.gold.connect(signer).increaseAllowance(this.vault.address, TOKEN_AMOUNT);
            await tx2.wait();
            await this.vault.receiveToken(this.nftcontract.address, creator, TOKEN_AMOUNT, { from: creator });

            // console.log(JSON.stringify(approval));
            vaultbalance = await this.vault.getVaultBalance();
            currentbalance = await this.vault.getCurrentBalance();
            console.log(vaultbalance.toString(10));
            console.log(currentbalance.toString(10));

            // //back to pre conditon
            assert.equal(await this.vault.getVaultBalance(), TOTAL_SUPPLY);
            assert.equal(await this.vault.getCurrentBalance(), 0);

            // //check if owner has token
            assert.equal(await this.nftcontract.balanceOf(creator), 1);
            assert.equal(await this.nftcontract.balanceOf(this.vault.address), 0);


            // //check if owner has token
            // assert.equal(await this.nftcontract.balanceOf(creator), 1);
            // assert.equal(await this.nftcontract.balanceOf(this.vault.address), 0);
        });

    })
})
