//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "hardhat/console.sol";

abstract contract ENS {
    function resolver(bytes32 node) public view virtual returns (Resolver);
}

abstract contract Resolver {
    function addr(bytes32 node) public view virtual returns (address);
}

contract MyNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    // total number of nfts
    uint256 constant totalSupply = 1;
    // keep track of number of items in collection
    Counters.Counter private _tokenIds;
    string extension = ".eth";
    string domain = "";
    string seperator = "";
    // keep track of
    ENS ens;
    string public signers = "";

    constructor() ERC721("MyNFT", "NFT") {
        ens = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
    }

    function resolve(bytes32 node) private view returns (address) {
        Resolver resolver = ens.resolver(node);
        return resolver.addr(node);
    }

    function computeHash(string memory ensdomain) private returns (bytes32) {
        bytes32 namehash = 0x0000000000000000000000000000000000000000000000000000000000000000;
        namehash = keccak256(
            abi.encodePacked(namehash, keccak256(abi.encodePacked("eth")))
        );
        namehash = keccak256(
            abi.encodePacked(namehash, keccak256(abi.encodePacked(ensdomain)))
        );
        return namehash;
    }

    function verifyHash(address sender, string memory ensdomain)
        private
        returns (bool)
    {
        bytes32 namehash = computeHash(ensdomain);
        if (resolve(namehash) == sender) return true;
        return false;
    }

    function signCard(string memory ensdomain) public returns (bool) {
        // require(
        //     verifyHash(msg.sender, ensdomain) == true,
        //     "This isn't your ens address"
        // );
        domain = string(abi.encodePacked(ensdomain, extension));

        if (bytes(signers).length > 0) seperator = "\n";
        else seperator = "";

        signers = string(abi.encodePacked(signers, seperator, domain));

        return true;
    }

    function getSigners() public view returns (string memory) {
        return signers;
    }

    // // method that'll be called for minting nft
    function mintNFT(address recipient, string memory tokenURI)
        public
        onlyOwner
        returns (uint256)
    {
        if (_tokenIds.current() < totalSupply) {
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _mint(recipient, newItemId);
            _setTokenURI(newItemId, tokenURI);
            return newItemId;
        }
        revert("Not found");
    }
}
