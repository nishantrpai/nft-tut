// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./GLDToken.sol";

contract NFTVault is IERC721Receiver {
    GLDToken gold;
    uint256[] public tokenIds;

    constructor() public {
        gold = new GLDToken("Gold", "GLD", 1000000);
    }

    function transferGold(
        address _from,
        address _to,
        uint256 amount
    ) public returns (bool success) {
        gold.approve(address(this), amount);
        return gold.transferFrom(_from, _to, amount);
    }

    function getVaultBalance() public view returns (uint256 balance) {
        return gold.balanceOf(address(this));
    }

    function getCurrentBalance() public view returns (uint256 balance) {
        return gold.balanceOf(msg.sender);
    }

    function getTokenAddr() public view returns (address token) {
        return address(gold);
    }

    function receiveToken(
        address contractAddress,
        address,
        uint256 amount
    ) public returns (bool success) {
        address from = msg.sender;
        require(gold.balanceOf(from) != 0, "sender cannot have 0 gold");
        // gold.approve(address(this), amount);
        // gold.increaseAllowance(address(this), amount);
        // gold.increaseAllowance(from, amount);
        if (gold.transferFrom(from, address(this), amount)) {
            IERC721(contractAddress).transferFrom(
                address(this),
                msg.sender,
                tokenIds[0]
            );
        }

        return false;
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory
    ) public virtual override returns (bytes4) {
        if (gold.transfer(_from, 100)) {
            tokenIds.push(_tokenId);
            return this.onERC721Received.selector;
        }
    }
}
