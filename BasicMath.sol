

// SPDX-License-Identifier: MIT
// Improved version by yang7777 for Base Learn Quest
pragma solidity ^0.8.0;

contract BasicMath {
    // 加算（オーバーフロー時は0を返す）
    function add(uint256 a, uint256 b) public pure returns (uint256 result, bool error) {
        unchecked {
            result = a + b;
            error = result < a;
            if (error) result = 0;
        }
    }

    // 減算（アンダーフロー時は0を返す）
    function sub(uint256 a, uint256 b) public pure returns (uint256 result, bool error) {
        if (a < b) {
            return (0, true);
        }
        return (a - b, false);
    }
}
