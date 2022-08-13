//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./WriteSVG.sol";


contract Present is ERC721URIStorage, Ownable, WriteSVG {
    using Counters for Counters.Counter;
    uint256 constant totalSupply = 1;
    Counters.Counter private _tokenIds;
    bool NFTGifted = false;
    string seperator = "";
    string signatures = "";
    uint256 x = 20;
    uint256 y = 55;
    uint256 height = 170;
    mapping(address => bool) signed;

    constructor() ERC721("HBD JCK", "NFT") {
    }

    function signSVG(string memory name) private returns (string memory) {
        y += 5;
        height += 10;
        return write(name,"#999",1,y*2);
    }

    function hasSpace(string memory name) internal returns (bool) {
        for(uint256 i = 0; i < bytes(name).length; i++) {
            bytes memory firstCharByte = new bytes(1);
			firstCharByte[0] = bytes(name)[i];
			uint8 decimal = uint8(firstCharByte[0]);
			if(decimal == 32) {
                return true;
            }
        }

        return false;
    }

    function signCard(string memory name) public returns (bool) {
        // require no-spaces
        require(!signed[msg.sender], "One-sign/Person");
        require(!(bytes(name).length <= 0), "Min chars 1");
        require(!(bytes(name).length >= 10), "Max chars 10");
        require(!NFTGifted, "NFT has been gifted");
        require(!hasSpace(name),"No spaces");
        signatures = string(abi.encodePacked(signatures,signSVG(name)));
        signed[msg.sender] = true;
        return true;
    }

    function tokenURI() internal returns (string memory) {
        string memory present = string(abi.encodePacked("<svg viewBox='0 0 100 ",Strings.toString(height),"' width='500' xmlns='http://www.w3.org/2000/svg'><rect x='0' y='0' width='100%' height='100%' fill='#000'/><g transform='scale(1) translate(44.5, 40)' fill='#fff' fill-rule='evenodd' clip-rule='evenodd' aria-label='HBD'><g transform='translate(0)'><path d='M0 0H1L1 2H2V0H3V2V3V5H2V3H1V5H0V0Z'/></g><g transform='translate(4)'><path d='M1 0H0V5H1H2H3V3H2V2H3V0H2H1ZM2 2H1V1H2V2ZM2 4V3H1V4H2Z'/></g><g transform='translate(8)'><path d='M0 1V4V5H1H2H3V1H2V0H1H0V1ZM2 4V1L1 1V4H2Z'/></g></g><g transform='scale(1) translate(42, 50)' fill='#fff' fill-rule='evenodd' clip-rule='evenodd' aria-label='JACK'><g transform='translate(0)'><g transform='translate(0)'><path d='M0 0H2H3V1V4V5H2H1H0V4V3H1V4H2V1L0 1V0Z'/></g><g transform='translate(4)'><path d='M0 3V5H1V3L2 3V5H3V3V2V1V0H2H1H0V1V2V3ZM1 2H2V1H1V2Z'/></g><g transform='translate(8)'><path d='M0 0H1H3V1L1 1V4H3V5H1H0V4V1V0Z'/></g><g transform='translate(12)'><path d='M1 0H0V2V3V5H1V3H2V5H3L3 3H2V2H3L3 0H2L2 2H1V0Z'/></g><g transform='translate(16)'><path d='M0 3H1L1 0H0V3ZM0 5H1L1 4H0V5Z'/></g></g></g>"));
        present = string(abi.encodePacked(present,signatures,"</svg>"));
        present = string(abi.encodePacked("data:image/svg+xml;base64,",Base64.encode(bytes(present))));
        

        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "HBD JCK",',
                '"image": "', present, '",',
                '"description": "Happy Birthday Jack - VV"'
                // Replace with extra ERC721 Metadata properties
            '}'
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    function mintNFT(address recipient) public onlyOwner returns (uint256) {
        if (!NFTGifted) {
            string memory _tokenURI = tokenURI();
            NFTGifted = true;
            uint256 newItemId = 34;
            _mint(recipient, newItemId);
            _setTokenURI(newItemId, _tokenURI);
            return newItemId;
        }
        revert("Not found");
    }
}
