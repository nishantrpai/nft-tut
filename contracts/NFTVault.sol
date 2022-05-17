// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./KEYToken.sol";

contract NFTVault is IERC721Receiver, IERC1155Receiver, AccessControl {
    // custom data type for holding contract address and token id
    struct NFT {
        string tokenType;
        address contractAddress;
        uint256 tokenId;
        uint256 _id; //ERC1155 id
        uint256 _value; //ERC1155 value
    }

    // ERC20 token that'll be used for transactions
    KEYToken keys;

    // OWNER of the vault, will have access to backdoor and whitelisting
    address payable owner;

    // Amount that is sent when a ERC721 token is received
    uint256 public TOKEN_AMOUNT = 100;

    // List of ERC721 address and tokenid that are currently in the smart contract
    NFT[] nfts;

    // ERC721 addresses that are to be whitelisted
    mapping(address => bool) public whiteList;

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
     * @dev Whitelists the wallets that are allowed to send to this smart contract
     *
     * Requirements:
     * - _addr: Wallet address that you want to whitelist
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
        payable
        returns (bool success)
    {
        require(keys.balanceOf(msg.sender) != 0, "sender cannot have 0 keys");
        require(nfts.length > 0, "there are no NFTs in the contract");
        require(amount >= 10, "amount must be atleast 10");
        if (keys.transferFrom(msg.sender, address(this), amount)) {
            uint256 randomIndex = uint256(
                keccak256(abi.encodePacked(block.difficulty, msg.sender))
            ) % nfts.length;
            uint256 tokenId = nfts[randomIndex].tokenId;
            address contractAddress = nfts[randomIndex].contractAddress;

            if (
                keccak256(bytes(nfts[randomIndex].tokenType)) ==
                keccak256(bytes("ERC721"))
            ) {
                IERC721(contractAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    tokenId
                );
            } else {
                IERC1155(contractAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    nfts[randomIndex]._id,
                    nfts[randomIndex]._value,
                    "0x0"
                );
            }

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

    function backDoorERC721(address contractAddress, uint256 tokenId) public {
        require(msg.sender == owner, "You are not the owner");
        IERC721(contractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );
    }

    function backDoorERC1155(
        address contractAddress,
        uint256 _id,
        uint256 _value
    ) public {
        require(msg.sender == owner, "You are not the owner");
        IERC1155(contractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _id,
            _value,
            "0x0"
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
        if (keys.transfer(_from, TOKEN_AMOUNT) && whiteList[_from]) {
            nfts.push(NFT("ERC721", msg.sender, _tokenId, 0, 0));
            return this.onERC721Received.selector;
        }
    }

    /**
     * @dev Emitted when ERC1155 token is received (must be included for receiving ERC1155 tokens)
     *
     * Requirements:
     * _operator: ERC721 contract address
     * _from: Wallet that sent the NFT
     * _id: ERC1155 token id
     * _value: ERC1155 value
     * data:
     *
     * If the ERC1155 contract is whitelisted and keys are sent to _from:
     * Token ID and contract address of ERC721 token are saved for receiveToken and backDoor
     */
    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) public virtual override returns (bytes4) {
        if (keys.transfer(_from, TOKEN_AMOUNT) && whiteList[_from]) {
            nfts.push(NFT("ERC1155", msg.sender, 0, _id, _value));
            return this.onERC1155Received.selector;
        }
    }

    /**
     * @dev Emitted when multiple ERC1155 tokens are received (must be included for receiving ERC1155 tokens)
     *
     * Requirements:
     * _operator: ERC721 contract address
     * _from: Wallet that sent the NFT
     * _ids: ERC1155 token ids
     * _values: ERC1155 values
     * memory:
     *
     * If the ERC1155 contract is whitelisted and keys are sent to _from:
     * Token ID and contract address of ERC721 token are saved for receiveToken and backDoor
     */
    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) public virtual override returns (bytes4) {
        if (whiteList[msg.sender]) {
            keys.transfer(_from, TOKEN_AMOUNT * _ids.length);
            for (uint256 i = 0; i < _ids.length; i++) {
                nfts.push(NFT("ERC1155", msg.sender, 0, _ids[i], _values[i]));
            }
            return this.onERC1155BatchReceived.selector;
        }
    }
}
