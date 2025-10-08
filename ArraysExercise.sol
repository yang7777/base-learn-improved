// SPDX-License-Identifier: MIT
// Improved version for Base Learn Quest
pragma solidity ^0.8.30;

/// @title Arrays Exercise Contract
/// @notice Demonstrates array manipulation, push-less reset, and timestamp filtering
contract ArraysExercise {
    // --- 初期動的配列 ---
    uint256[] public numbers = [uint256(1),2,3,4,5,6,7,8,9,10];

    // 追加要件：送信者とタイムスタンプの記録
    address[] public senders;
    uint256[] public timestamps;

    uint256 constant Y2K = 946_702_800; // 2000-01-01 00:00:00 UTC

    /// @notice Returns the full numbers array
    function getNumbers() external view returns (uint256[] memory) {
        return numbers;
    }

    /// @notice Resets numbers array to 1..10 without using .push()
    function resetNumbers() external {
        numbers = [uint256(1),2,3,4,5,6,7,8,9,10];
    }

    /// @notice Appends an array of numbers to the existing numbers array
    /// @param _toAppend Array of numbers to append
    function appendToNumbers(uint256[] calldata _toAppend) external {
        for (uint256 i = 0; i < _toAppend.length; i++) {
            numbers.push(_toAppend[i]);
        }
    }

    /// @notice Saves msg.sender and a Unix timestamp
    /// @param _unixTimestamp Timestamp to save
    function saveTimestamp(uint256 _unixTimestamp) external {
        senders.push(msg.sender);
        timestamps.push(_unixTimestamp);
    }

    /// @notice Returns timestamps and senders after Y2K
    /// @return ts Array of timestamps after Y2K
    /// @return addrs Array of addresses corresponding to ts
    function afterY2K() external view returns (uint256[] memory ts, address[] memory addrs) {
        uint256 count;
        for (uint256 i = 0; i < timestamps.length; i++) {
            if (timestamps[i] > Y2K) count++;
        }

        ts = new uint256[](count);
        addrs = new address[](count);

        uint256 idx;
        for (uint256 i = 0; i < timestamps.length; i++) {
            if (timestamps[i] > Y2K) {
                ts[idx] = timestamps[i];
                addrs[idx] = senders[i];
                idx++;
            }
        }
    }

    /// @notice Resets the senders array
    function resetSenders() external {
        delete senders;
    }

    /// @notice Resets the timestamps array
    function resetTimestamps() external {
        delete timestamps;
    }
}
