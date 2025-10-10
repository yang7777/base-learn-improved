// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice 承認外のレコード名を渡したとき
error NotApproved(string name);

/// @title FavoriteRecords
/// @notice ユーザーがお気に入りの音楽レコードを管理できるコントラクト
contract FavoriteRecords {
    // --- State ---
    // 承認済みレコード（存在確認用）
    mapping(string => bool) public approvedRecords;
    // 承認済みレコードの「名前一覧」（mappingはキー列挙できないため別で保持）
    string[] private approvedList;

    // ユーザーごとのお気に入り（存在確認用）
    mapping(address => mapping(string => bool)) public userFavorites;
    // ユーザーごとの「お気に入り名の配列」
    mapping(address => string[]) private userFavoriteList;

    // --- Events ---
    event RecordApproved(string name);
    event RecordAddedToFavorites(address indexed user, string name);
    event UserFavoritesReset(address indexed user);

    // --- Constructor: 初期承認レコードをロード ---
    constructor() {
        string[9] memory initialRecords = [
            "Thriller",
            "Back in Black",
            "The Bodyguard",
            "The Dark Side of the Moon",
            "Their Greatest Hits (1971-1975)",
            "Hotel California",
            "Come On Over",
            "Rumours",
            "Saturday Night Fever"
        ];

        for (uint256 i = 0; i < initialRecords.length; i++) {
            _approve(initialRecords[i]);
        }
    }

    // --- Internal: 承認リストに追加 ---
    function _approve(string memory name) internal {
        if (!approvedRecords[name]) {
            approvedRecords[name] = true;
            approvedList.push(name);
            emit RecordApproved(name);
        }
    }

    // --- External: 管理者用に承認追加（例として msg.sender = owner に制限可） ---
    function approveRecord(string calldata name) external {
        _approve(name);
    }

    // --- Get Approved Records ---
    function getApprovedRecords() external view returns (string[] memory) {
        return approvedList;
    }

    // --- Add Record to Favorites ---
    function addRecord(string calldata name) external {
        if (!approvedRecords[name]) revert NotApproved(name);

        if (!userFavorites[msg.sender][name]) {
            userFavorites[msg.sender][name] = true;
            userFavoriteList[msg.sender].push(name);
            emit RecordAddedToFavorites(msg.sender, name);
        }
    }

    // --- Users’ Lists ---
    function getUserFavorites(address user) external view returns (string[] memory) {
        return userFavoriteList[user];
    }

    // --- Reset My Favorites ---
    function resetUserFavorites() external {
        string[] storage list = userFavoriteList[msg.sender];

        // mappingをリセット
        for (uint256 i = 0; i < list.length; i++) {
            userFavorites[msg.sender][list[i]] = false;
        }

        // 配列を空に
        delete userFavoriteList[msg.sender];

        emit UserFavoritesReset(msg.sender);
    }
}
