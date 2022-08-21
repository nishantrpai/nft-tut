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
        address contractAddress;
        uint256 tokenId;
        uint256 value; //ERC1155 value
    }

    // ERC20 token that'll be used for transactions
    KEYToken keys;

    // OWNER of the vault, will have access to backdoor and whitelisting
    address payable owner;

    // Base unit is used for display purposes
    uint256 public BASE_UNIT = 10 ** 18;

    // Amount that is sent when a ERC721 token is received
    uint256 public TOKEN_AMOUNT = 100 * BASE_UNIT;


    // Total supply of keys
    uint256 public TOTAL_SUPPLY = 100000 * BASE_UNIT;

    //Minimum number of KEYS contract needs to receive to pick a random NFT
    uint256 public MIN_AMOUNT_OF_KEYS_TO_RECIEVE_TOKEN = 10;

    // List of ERC721 address and tokenid that are currently in the smart contract
    NFT[] nfts;

    // ERC721 addresses that are to be whitelisted
    mapping(address => bool) public whiteList;

    /**
     * @dev Emitted when this contract is deployed
     */
    constructor() public {
        keys = new KEYToken("KEYS", "KEY", TOTAL_SUPPLY);
        owner = payable(msg.sender);
    }

    /**
     * @dev Returns the amount of keys in this vault
     */
    function getVaultBalance() public view returns (uint256 balance) {
        return keys.balanceOf(address(this));
    }

    /**
     * @dev Returns the amount of keys in senders account.
     */
    function getCurrentBalance() public view returns (uint256 balance) {
        return keys.balanceOf(msg.sender);
    }

    /**
     * @dev Get token type whether it is ERC721 or ERC1155
     */
    function getTokenType(address addr)
        public
        view
        returns (string memory tokenType)
    {
        if (IERC721(addr).supportsInterface(0x80ac58cd)) return "ERC721";
        if (IERC1155(addr).supportsInterface(0xd9b67a26)) return "ERC1155";
        return "unknown";
    }

    /**
     * @dev Returns the address of keys (ERC20 contract) that is deployed
     */
    function getTokenAddr() public view returns (address token) {
        return address(keys);
    }

    /**
     * @dev Whitelists the wallets that are allowed to send ERC721/ERC1155 tokens to this contract
     *
     * Requirements:
     * - addr: Wallet address that you want to whitelist
     * - isWhiteListed: Whitelist/Blacklist contract based on value
     */
    function setWhiteList(address addr, bool isWhiteListed) public {
        require(msg.sender == owner, "You are not the owner");
        whiteList[addr] = isWhiteListed;
    }

    /**
     * @dev Send NFT to the wallet (that called) AFTER >=10 keys(ERC20 token) are sent to this function
     *
     * Requirements:
     * - amount: Amount of keys (ERC20 token) that is being sent to the smart contract
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
        require(amount >= MIN_AMOUNT_OF_KEYS_TO_RECIEVE_TOKEN * BASE_UNIT, "amount must be atleast 10");
        if (keys.transferFrom(msg.sender, address(this), amount)) {
            uint256 randomIndex = uint256(
                keccak256(abi.encodePacked(block.difficulty, msg.sender))
            ) % nfts.length;

            if (
                keccak256(bytes(getTokenType(nfts[randomIndex].contractAddress))) ==
                keccak256(bytes("ERC721"))
            ) {
                IERC721(nfts[randomIndex].contractAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    nfts[randomIndex].tokenId
                );
            }

            if (
                keccak256(bytes(getTokenType(nfts[randomIndex].contractAddress))) ==
                keccak256(bytes("ERC1155"))
            ) {
                IERC1155(nfts[randomIndex].contractAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    nfts[randomIndex].tokenId,
                    nfts[randomIndex].value,
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
     * @dev Owner can use this function for preventing ERC721 from getting locked in this contract
     *
     * Requirements:
     * -contractAddress: Contract address of ERC721 token
     * -tokenId: TokenID of ERC721
     */
    function backDoorERC721(address contractAddress, uint256 tokenId) public {
        require(msg.sender == owner, "You are not the owner");
        IERC721(contractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );
    }

    /**
     * @dev Owner can use this function for preventing ERC1155 from getting locked in this contract
     *
     * Requirements:
     * -contractAddress: Contract address of ERC1155 token
     * -id: token id of ERC1155
     * -value: amount of tokens (id) you want to send
     */
    function backDoorERC1155(
        address contractAddress,
        uint256 id,
        uint256 value
    ) public {
        require(msg.sender == owner, "You are not the owner");
        IERC1155(contractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            id,
            value,
            "0x0"
        );
    }

    /**
     * @dev Emitted when ERC721 token is received (must be included for receiving ERC721 tokens)
     *
     * Requirements:
     * from: Wallet that sent the NFT
     * tokenId: ERC721 tokenid
     * memory:
     *
     * If the ERC721 contract is whitelisted and keys are sent to from:
     * Token ID and contract address of ERC721 token are saved for receiveToken and backDoor
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory
    ) public virtual override returns (bytes4) {
        if (whiteList[from]) {
            if (keys.transfer(from, TOKEN_AMOUNT)) {
                nfts.push(NFT(msg.sender, tokenId, 0));
                return this.onERC721Received.selector;
            }
        }
    }

    /**
     * @dev Emitted when ERC1155 token is received (must be included for receiving ERC1155 tokens)
     *
     * Requirements:
     * from: Wallet that sent the NFT
     * id: ERC1155 token id
     * value: ERC1155 value
     * data:
     *
     * If the ERC1155 contract is whitelisted and keys are sent to from:
     * Token ID and contract address of ERC721 token are saved for receiveToken and backDoor
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) public virtual override returns (bytes4) {
        if (whiteList[from]) {
            if (keys.transfer(from, TOKEN_AMOUNT)) {
                nfts.push(NFT(msg.sender, id, value));
                return this.onERC1155Received.selector;
            }
        }
    }

    /**
     * @dev Emitted when multiple ERC1155 tokens are received (must be included for receiving ERC1155 tokens)
     *
     * Requirements:
     * from: Wallet that sent the NFT
     * ids: ERC1155 token ids
     * values: ERC1155 values
     * memory:
     *
     * If the ERC1155 contract is whitelisted and keys are sent to from:
     * Token ID and contract address of ERC721 token are saved for receiveToken and backDoor
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) public virtual override returns (bytes4) {
        if (whiteList[from]) {
            keys.transfer(from, TOKEN_AMOUNT * ids.length);
            for (uint256 i = 0; i < ids.length; i++) {
                nfts.push(NFT(msg.sender, ids[i], values[i]));
            }
            return this.onERC1155BatchReceived.selector;
        }
    }
}
