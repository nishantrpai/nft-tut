const { assert } = require("hardhat");

const Gold = artifacts.require("../contracts/GLDToken.sol");

contract("GLDToken", ([creator, other]) => {
    const NAME = 'GLDToken';
    const SYMBOL = 'GOLD';
    const TOTAL_SUPPLY = 100;

    it("should create gold", async function () {
        const token = await Gold.new(NAME, SYMBOL, TOTAL_SUPPLY, { from: creator });
        assert.equal(await token.totalSupply(), TOTAL_SUPPLY);
        assert.equal(await token.balanceOf(creator), TOTAL_SUPPLY);
    });
})