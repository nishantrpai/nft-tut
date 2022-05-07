// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "hardhat/console.sol";
import "./GLDToken.sol";

contract NFTVault is IERC721Receiver {
    struct NFT {
        address contractAddress;
        uint256 tokenId;
    }
    // gold for erc20
    GLDToken gold;
    address payable public owner;

    //
    NFT[] nfts;
    mapping(address => uint256[]) public tokens;
    mapping(address => bool) whiteList;

    // contract array

    constructor() public {
        gold = new GLDToken("Gold", "GLD", 1000000);
        owner = payable(msg.sender);
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

    function setWhiteList(address _addr, bool _whiteList) public {
        require(msg.sender == owner, "You are not the owner");
        whiteList[_addr] = _whiteList;
    }

    function receiveToken(address, uint256 amount)
        public
        returns (bool success)
    {
        console.log("balance %s", gold.balanceOf(msg.sender));
        require(gold.balanceOf(msg.sender) != 0, "sender cannot have 0 gold");
        require(nfts.length > 0, "no nfts added");
        if (gold.transferFrom(msg.sender, address(this), amount)) {
            // get random nft
            uint256 randomIndex = uint256(
                keccak256(abi.encodePacked(block.difficulty, msg.sender))
            ) % nfts.length;
            uint256 tokenId = nfts[randomIndex].tokenId;
            address contractAddress = nfts[randomIndex].contractAddress;

            console.log("----");
            console.log("token length %s", nfts.length);
            console.log("contractaddress %s", contractAddress);
            console.log("random index %s", randomIndex);
            console.log("tokenid %s", tokenId);
            IERC721(contractAddress).transferFrom(
                address(this),
                msg.sender,
                tokenId
            );

            require(randomIndex < nfts.length);
            nfts[randomIndex] = nfts[nfts.length - 1];
            nfts.pop();

            console.log("token length %s", nfts.length);
            console.log("----");

            return true;
        }

        return false;
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory
    ) public virtual override returns (bytes4) {
        if (gold.transfer(_from, 100) && whiteList[msg.sender]) {
            //first time new contract is showing up
            nfts.push(NFT(msg.sender, _tokenId));
            return this.onERC721Received.selector;
        }
    }
}
