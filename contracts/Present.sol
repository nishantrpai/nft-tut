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


contract Present is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    uint256 constant totalSupply = 1;
    Counters.Counter private _tokenIds;
    string seperator = "";
    string present = '<?xml version="1.0" standalone="no"?><!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 20010904//EN" "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd"><svg version="1.0" xmlns="http://www.w3.org/2000/svg" width="1024.000000pt" height="1024.000000pt" viewBox="0 0 2160.000000 2160.000000" preserveAspectRatio="xMidYMid meet"><g transform="translate(0.000000,2160.000000) scale(0.100000,-0.100000)" fill="#000000" stroke="none"><path d="M0 10800 l0 -10800 10800 0 10800 0 0 10800 0 10800 -10800 0 -10800 0 0 -10800z m9585 1652 c268 -75 472 -252 560 -486 38 -102 55 -220 55 -392 l0 -154 -304 0 -304 0 -4 173 c-3 153 -6 177 -25 213 -28 52 -96 112 -137 119 -17 3 -275 5 -573 3 l-541 -3 -43 -30 c-27 -19 -54 -50 -71 -84 l-28 -53 0 -1007 0 -1006 24 -51 c30 -64 85 -110 148 -124 61 -13 1016 -13 1072 0 59 13 117 59 145 115 l26 49 3 363 3 363 -358 2 -358 3 -3 278 -2 277 665 0 665 0 0 -634 c0 -694 -3 -737 -59 -881 -81 -210 -264 -380 -486 -454 -151 -50 -198 -53 -830 -48 -565 3 -582 4 -660 26 -263 74 -456 241 -549 475 -57 144 -57 128 -54 1272 4 1164 -1 1082 70 1237 85 185 250 335 448 407 156 57 179 59 830 56 581 -2 597 -2 675 -24z m2540 -522 c259 -302 475 -549 480 -549 6 0 29 26 52 58 73 100 338 419 772 928 l96 112 248 1 247 0 0 -1740 0 -1740 -305 0 -305 0 0 1240 0 1241 -317 -366 -318 -365 -185 0 -185 0 -315 362 -315 363 -3 -1238 -2 -1237 -305 0 -305 0 0 1740 0 1740 248 0 247 -1 470 -549z"/></g>';
    string public signers = "";
    uint256 x = 20;
    uint256 y = 10;

    constructor() ERC721("Happy Birthday Jack", "NFT") {
    }


    function signSVG(string memory name) private returns (string memory) {
        y += 40;
        return string(abi.encodePacked('<text x="10" y="',Strings.toString(y),'" fill="gray" font-size="2em">',name,'</text>'));
    }

    function signCard(string memory name) public returns (bool) {
        present = string(abi.encodePacked(present,signSVG(name)));
        return true;
    }

function tokenURI()
        public
        returns (string memory)
    {
        
        present = string(abi.encodePacked(present,"</svg>"));
        present = string(abi.encodePacked("data:image/svg+xml;base64,",Base64.encode(bytes(present))));
        console.log(present);


        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Happy Birthday Jack',
                '"image": "', present, '"'
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
    function mintNFT(address recipient)
        public
        onlyOwner
        returns (uint256)
    {
        if (_tokenIds.current() < totalSupply) {
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _mint(recipient, newItemId);
            
            _setTokenURI(newItemId, tokenURI());
            return newItemId;
        }
        revert("Not found");
    }
}
