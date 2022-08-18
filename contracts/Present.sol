// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./WriteSVG.sol";

contract Present is ERC721, WriteSVG {
    mapping(address => bool) signed;

    constructor() ERC721("Clock", "CLCK") {
        _safeMint(msg.sender, 1);
    }

    /// @dev There can ever only be one token. HBD JCK.
    function totalSupply() public pure returns (uint256) {
        return 1;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(tokenId == 1,"Nah");

        string memory clock = "data:text/html;base64,PCFET0NUWVBFIGh0bWw+DQo8aHRtbD4NCjxzdHlsZT4NCiNjb250YWluZXIgew0KICB3aWR0aDogNDAwcHg7DQogIGhlaWdodDogNDAwcHg7DQogIHBvc2l0aW9uOiByZWxhdGl2ZTsNCiAgYmFja2dyb3VuZDogeWVsbG93Ow0KfQ0KI2FuaW1hdGUgew0KICB3aWR0aDogNTBweDsNCiAgaGVpZ2h0OiA1MHB4Ow0KICBwb3NpdGlvbjogYWJzb2x1dGU7DQogIGJhY2tncm91bmQtY29sb3I6IHJlZDsNCn0NCjwvc3R5bGU+DQo8Ym9keT4NCg0KPHA+PGJ1dHRvbiBvbmNsaWNrPSJteU1vdmUoKSI+Q2xpY2sgTWU8L2J1dHRvbj48L3A+IA0KDQo8ZGl2IGlkID0iY29udGFpbmVyIj4NCiAgPGRpdiBpZCA9ImFuaW1hdGUiPjwvZGl2Pg0KPC9kaXY+DQoNCjxzY3JpcHQ+DQpmdW5jdGlvbiBteU1vdmUoKSB7DQogIGxldCBpZCA9IG51bGw7DQogIGNvbnN0IGVsZW0gPSBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgiYW5pbWF0ZSIpOyAgIA0KICBsZXQgcG9zID0gMDsNCiAgY2xlYXJJbnRlcnZhbChpZCk7DQogIGlkID0gc2V0SW50ZXJ2YWwoZnJhbWUsIDUpOw0KICBmdW5jdGlvbiBmcmFtZSgpIHsNCiAgICBpZiAocG9zID09IDM1MCkgew0KICAgICAgY2xlYXJJbnRlcnZhbChpZCk7DQogICAgfSBlbHNlIHsNCiAgICAgIHBvcysrOyANCiAgICAgIGVsZW0uc3R5bGUudG9wID0gcG9zICsgInB4IjsgDQogICAgICBlbGVtLnN0eWxlLmxlZnQgPSBwb3MgKyAicHgiOyANCiAgICB9DQogIH0NCn0NCjwvc2NyaXB0Pg0KDQo8L2JvZHk+DQo8L2h0bWw+DQo=";

        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "HBD JCK",',
                '"description": "Happy Birthday Jack - VV",',
                '"animation_url": "', clock, '"'
            '}'
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }
}
