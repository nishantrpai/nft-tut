//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    // total number of nfts
    uint256 constant totalSupply = 10;
    // keep track of number of items in collection
    Counters.Counter private _tokenIds;
    // keep track of
    mapping(address => uint256) public balances;

    // called when contract is created
    function initialize() public {
        balances[0x5A8064F8249D079f02bfb688f4AA86B6b2C65359] = 2;
    }

    constructor() ERC721("MyNFT", "NFT") {
        initialize();
    }

    // check balance for an address
    function balanceAddr(address recipient)
        public
        view
        returns (uint256 balance)
    {
        return balances[recipient];
    }

    function numberOfTokensLeft() public view returns (uint256) {
        return totalSupply - _tokenIds.current();
    }

    // method that'll be called for minting nft
    function mintNFT(address recipient, string memory tokenURI)
        public
        onlyOwner
        returns (uint256)
    {
        if (balances[recipient] > 0 && _tokenIds.current() < totalSupply) {
            _tokenIds.increment();

            uint256 newItemId = _tokenIds.current();
            _mint(recipient, newItemId);
            _setTokenURI(newItemId, tokenURI);
            balances[recipient]--;
            return newItemId;
        }
        revert("Not found");
    }
}
