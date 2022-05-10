// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./KEYToken.sol";

contract NFTVault is IERC721Receiver {
    struct NFT {
        address contractAddress;
        uint256 tokenId;
    }

    KEYToken keys;
    address payable public owner;
    uint256 public TOKEN_AMOUNT = 100;
    NFT[] nfts;
    mapping(address => uint256[]) public tokens;
    mapping(address => bool) whiteList;

   
    /**
     * @dev Emitted when this contract is deployed
     */
    constructor() public {
        keys = new KEYToken("KEYS", "KEY", 1000000);
        owner = payable(msg.sender);
    }

    /**
     * @dev Returns the token balance for the vault
     */
    function getVaultBalance() public view returns (uint256 balance) {
        return keys.balanceOf(address(this));
    }

    /**
     * @dev Returns the number of tokens in senders account.
     */
    function getCurrentBalance() public view returns (uint256 balance) {
        return keys.balanceOf(msg.sender);
    }

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function getTokenAddr() public view returns (address token) {
        return address(keys);
    }

    /**
     * @dev Whitelists the contracts that are allowed to send to this smart contract
     *
     * Requirements:
     * - _addr: Contract address that you want to whitelist
     * - _whitelist: Whitelist/Blacklist contract based on value
     */
    function setWhiteList(address _addr, bool _whiteList) public {
        require(msg.sender == owner, "You are not the owner");
        whiteList[_addr] = _whiteList;
    }

    /**
     * @dev Send NFT to the wallet that is calling this function
     *
     * Requirements:
     * - amount: Amount that is being sent to the smart contract
     * 
     * Transfer amount from sender to this contract and a random ERC721 from this contract if:
     * 1. Wallet should have > 0 keys, will fail if there are no keys
     * 2. NFTs in the this contract should be > 0, will fail if there are no NFTs
     * 3. Amount that is being sent to the smart should be exactly 10, will failif the amount is not equal to 10
     */
    function receiveToken(uint256 amount)
        public
        returns (bool success)
    {
        require(keys.balanceOf(msg.sender) != 0, "sender cannot have 0 keys");
        require(nfts.length > 0, "there are no NFTs in the contract");
        require(amount == 10, "amount must be 10");
        if (keys.transferFrom(msg.sender, address(this), amount)) {
            uint256 randomIndex = uint256(
                keccak256(abi.encodePacked(block.difficulty, msg.sender))
            ) % nfts.length;
            uint256 tokenId = nfts[randomIndex].tokenId;
            address contractAddress = nfts[randomIndex].contractAddress;

            IERC721(contractAddress).transferFrom(
                address(this),
                msg.sender,
                tokenId
            );

            require(randomIndex < nfts.length);
            nfts[randomIndex] = nfts[nfts.length - 1];
            nfts.pop();

            return true;
        }
        return false;
    }


    /**
     * @dev Owner can use this function for preventing NFTs from getting locked in this contract
     * 
     * Requirements:
     * -contractAddress: Contract address of NFT
     * -tokenId: TokenID of NFT 
     */

    function backDoor(address contractAddress, uint256 tokenId) public {
        require(msg.sender == owner, "You are not the owner");
        IERC721(contractAddress).transferFrom(
            address(this),
            msg.sender,
            tokenId
        );
    }

    /**
     * @dev Emitted when ERC721 token is received (must be included for receiving ERC721 tokens)
     *
     * Requirements:
     * _operator: ERC721 contract address
     * _from: Wallet that sent the NFT
     * _tokenId:
     * memory:
     *
     * If the ERC721 contract is whitelisted and keys are sent to _from:
     * Token ID and contract address of ERC721 token are saved for receiveToken and backDoor 
     */
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory
    ) public virtual override returns (bytes4) {
        if (keys.transfer(_from, TOKEN_AMOUNT) && whiteList[msg.sender]) {
            nfts.push(NFT(msg.sender, _tokenId));
            return this.onERC721Received.selector;
        }
    }
}
