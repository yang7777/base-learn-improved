// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/utils/Strings.sol";

contract HaikuNFT is ERC721 {
    using Strings for uint256;

    /* ======================= Types & Errors ======================= */
    struct Haiku {
        address author;
        string line1;
        string line2;
        string line3;
    }

    error HaikuNotUnique();
    error NotYourHaiku(uint256 id);
    error NoHaikusShared();
    error InvalidInput();
    error AlreadyShared(uint256 id, address to);

    /* ======================= Events ======================= */
    event HaikuMinted(address indexed author, uint256 indexed id);
    event HaikuShared(uint256 indexed id, address indexed from, address indexed to);

    /* ======================= Storage ======================= */
    Haiku[] public haikus; // index 0 はダミー
    mapping(address => uint256[]) public sharedHaikus;
    mapping(bytes32 => bool) private usedLineHash;
    mapping(address => mapping(uint256 => bool)) private alreadyShared; // 重複共有防止

    uint256 public counter;

    /* ======================= Constructor ======================= */
    constructor() ERC721("Haiku NFT", "HAIKU") {
        haikus.push(); // index 0占位
        counter = 1;
    }

    /* ======================= Mint ======================= */
    function mintHaiku(
        string calldata line1,
        string calldata line2,
        string calldata line3
    ) external {
        // 入力チェック
        if (
            bytes(line1).length == 0 ||
            bytes(line2).length == 0 ||
            bytes(line3).length == 0
        ) revert InvalidInput();

        // keccak事前計算でガス節約
        bytes32 h1 = keccak256(bytes(line1));
        bytes32 h2 = keccak256(bytes(line2));
        bytes32 h3 = keccak256(bytes(line3));

        // ユニーク性チェック
        if (usedLineHash[h1] || usedLineHash[h2] || usedLineHash[h3]) {
            revert HaikuNotUnique();
        }

        uint256 id = counter;
        _safeMint(msg.sender, id);

        haikus.push(Haiku(msg.sender, line1, line2, line3));

        // 使用済みに登録
        usedLineHash[h1] = true;
        usedLineHash[h2] = true;
        usedLineHash[h3] = true;

        emit HaikuMinted(msg.sender, id);

        counter = id + 1;
    }

    /* ======================= Share ======================= */
    function shareHaiku(uint256 id, address to) external {
        if (ownerOf(id) != msg.sender) revert NotYourHaiku(id);
        if (to == address(0)) revert InvalidInput();
        if (alreadyShared[to][id]) revert AlreadyShared(id, to);

        sharedHaikus[to].push(id);
        alreadyShared[to][id] = true;

        emit HaikuShared(id, msg.sender, to);
    }

    /* ======================= Views ======================= */
    function getMySharedHaikus() external view returns (Haiku[] memory) {
        uint256[] storage ids = sharedHaikus[msg.sender];
        uint256 len = ids.length;
        if (len == 0) revert NoHaikusShared();

        Haiku[] memory out = new Haiku[](len);
        for (uint256 i = 0; i < len; i++) {
            out[i] = haikus[ids[i]];
        }
        return out;
    }

    function getHaiku(uint256 id) external view returns (Haiku memory) {
        require(id > 0 && id < haikus.length, "Invalid ID");
        return haikus[id];
    }

    /* ======================= Optional: 全俳句一覧 ======================= */
    function getAllHaikus() external view returns (Haiku[] memory) {
        uint256 len = haikus.length;
        if (len <= 1) revert NoHaikusShared(); // 0番はダミー
        Haiku[] memory all = new Haiku[](len - 1);
        for (uint256 i = 1; i < len; i++) {
            all[i - 1] = haikus[i];
        }
        return all;
    }

    /* ======================= Metadata Hook ======================= */
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://haiku-meta/";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);
        return string(abi.encodePacked(_baseURI(), tokenId.toString(), ".json"));
    }
}
