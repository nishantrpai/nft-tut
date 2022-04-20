// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GLDToken.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "hardhat/console.sol";

contract NFTVault is IERC721Receiver {
    GLDToken gold;

    constructor() public {
        gold = new GLDToken("Gold", "GLD", 1000000);
    }

    function getVaultBalance() public view returns (uint256 balance) {
        return gold.balanceOf(address(this));
    }

    function getCurrentBalance() public view returns (uint256 balance) {
        return gold.balanceOf(msg.sender);
    }

    function sendGold() public returns (bool success) {
        return gold.transfer(msg.sender, 100);
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        console.log("triggered %s %s", _operator, _from);
        if (gold.transfer(_from, 100)) {
            return this.onERC721Received.selector;
        }
    }
}
