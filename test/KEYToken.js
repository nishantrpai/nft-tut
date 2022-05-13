const { assert, artifacts, contract, expect, ethers } = require("hardhat");

const Vault = artifacts.require("../contracts/NFTVault.sol");
const NFT = artifacts.require("../contracts/NFT.sol");
const gameContract = artifacts.require("../contracts/GameItems.sol");

contract("NFTVault", ([creator, other]) => {
    const TOTAL_SUPPLY = 1000000;
    const TOKEN_AMOUNT = 10;

    it("should create vault", async function () {
        this.vault = await Vault.new();
        this.keyAddr = await this.vault.getTokenAddr();

        const keyArtifact = await artifacts.readArtifact("KEYToken");
        this.keys = await ethers.getContractAt(keyArtifact.abi, this.keyAddr, ethers.provider);

        assert.equal(await this.keys.totalSupply(), TOTAL_SUPPLY);

        assert.equal(await this.vault.getVaultBalance(), TOTAL_SUPPLY);
    });

    it("should create a ERC721 token", async function () {

        this.nftcontract = await NFT.new();
        this.token = [];
        this.token.push(await this.nftcontract.mintNFT(creator, "ipfs://QmQc4SpF3tMQgP5CCxtoaFtJJTTT8h4CjdSN4X9iFMCxoF"));
        for (let i = 0; i < this.token.length; i++) {
            assert.equal(this.token[i].logs[0].args.tokenId, 1);
        }
    });

    it("should create a ERC1155 token", async function () {
        this.gameContract = await gameContract.new();
        assert.equal(await this.gameContract.balanceOf(creator, 3), 1000000000);
        await this.vault.setWhiteList(this.gameContract.address, true);
    });


    it("should transfer ERC1155 for ERC20", async function () {
        await this.gameContract.safeTransferFrom(creator, this.vault.address, 3, 1, '0x0');
        assert.equal(await this.gameContract.balanceOf(this.vault.address, 3), 1);
        assert.equal(await this.vault.getCurrentBalance(), 100);
    });

    it("should transfer ERC20 for ERC1155", async function () {
        assert.notEqual(await this.gameContract.balanceOf(creator, 3), 1000000000);
        const signer = await ethers.provider.getSigner(creator)
        const tx1 = await this.keys.connect(signer).approve(this.vault.address, TOKEN_AMOUNT);
        await tx1.wait();
        const tx2 = await this.keys.connect(signer).increaseAllowance(this.vault.address, TOKEN_AMOUNT);
        await tx2.wait();
        await this.vault.receiveToken(10);
        assert.equal(await this.gameContract.balanceOf(creator, 3), 1000000000);
    });


    it("should transfer ERC20 for ERC721", async function () {
        //pre condition
        //check vault balance
        assert.equal(await this.vault.getVaultBalance(), TOTAL_SUPPLY - 90);
        assert.equal(await this.vault.getCurrentBalance(), 90);

        //check if owner has token
        assert.equal(await this.nftcontract.balanceOf(creator), this.token.length);
        assert.equal(await this.nftcontract.balanceOf(this.vault.address), 0);

        //whitelist address to send, will fail otherwise
        await this.vault.setWhiteList(this.nftcontract.address, true);
        // await this.vault.setWhiteList(this.nftcontract2.address, true);

        //transfer nft token to vault
        for (let i = 0; i < this.token.length; i++) {
            //will send 100 to creator
            await this.nftcontract.safeTransferFrom(creator, this.vault.address, this.token[i].logs[0].args.tokenId);
        }

        //post condition

        // check if vault has token
        assert.equal(await this.nftcontract.balanceOf(creator), 0);
        assert.equal(await this.nftcontract.balanceOf(this.vault.address), this.token.length);

        // check if vault has token
        // assert.equal(await this.nftcontract2.balanceOf(creator), 0);
        // assert.equal(await this.nftcontract2.balanceOf(this.vault.address), this.token2.length);

        //check if creator has erc20 tokens
        vaultbalance = await this.vault.getVaultBalance();
        assert.equal(await this.vault.getVaultBalance(), TOTAL_SUPPLY - 190);
        assert.equal(await this.vault.getCurrentBalance(), 190);
    });


    it("should send all ERC721 tokens for ERC20", async function () {

        //transfer erc20 from creator to vault
        // need owners approval
        for (let i = 0; i < this.token.length; i++) {
            const signer = await ethers.provider.getSigner(creator)
            const tx1 = await this.keys.connect(signer).approve(this.vault.address, TOKEN_AMOUNT);
            await tx1.wait();
            const tx2 = await this.keys.connect(signer).increaseAllowance(this.vault.address, TOKEN_AMOUNT);
            await tx2.wait();
            await this.vault.receiveToken(10);
        }

        //back to pre conditon
        assert.equal(await this.vault.getVaultBalance(), TOTAL_SUPPLY - 180);
        assert.equal(await this.vault.getCurrentBalance(), 180);

        // //check if owner has token
        assert.equal(await this.nftcontract.balanceOf(creator), this.token.length);
        assert.equal(await this.nftcontract.balanceOf(this.vault.address), 0);
    });

})
