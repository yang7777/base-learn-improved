// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

library SillyStringUtils {
    struct Haiku {
        string line1;
        string line2;
        string line3;
    }

    /// @dev 入力文字列の末尾に「🤷」を付ける
    function shruggie(string memory _input) public pure returns (string memory) {
        return string.concat(_input, unicode" 🤷");
    }

    /// @dev Haikuを作成するヘルパー関数
    function createHaiku(
        string memory _line1,
        string memory _line2,
        string memory _line3
    ) public pure returns (Haiku memory) {
        return Haiku(_line1, _line2, _line3);
    }

    /// @dev Haikuを文字列に変換（改行付き）
    function haikuToString(Haiku memory _haiku) public pure returns (string memory) {
        return string.concat(_haiku.line1, "\n", _haiku.line2, "\n", _haiku.line3);
    }
}
