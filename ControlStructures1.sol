// SPDX-License-Identifier: MIT
// Improved version for Base Learn Quest
pragma solidity ^0.8.30;

/// @notice Custom error for after-hours access
error AfterHours(uint256 providedTime);

/// @title Control Structures Examples
/// @notice Demonstrates FizzBuzz and time-based greeting logic
contract ControlStructures {

    /// @notice Classic FizzBuzz implementation
    /// @param _number Number to evaluate
    /// @return Result string: "Fizz", "Buzz", "FizzBuzz", or "Splat"
    function fizzBuzz(uint256 _number) external pure returns (string memory) {
        bool divisibleBy3 = (_number % 3 == 0);
        bool divisibleBy5 = (_number % 5 == 0);

        if (divisibleBy3 && divisibleBy5) return "FizzBuzz";
        if (divisibleBy3) return "Fizz";
        if (divisibleBy5) return "Buzz";
        return "Splat";
    }

    /// @notice Returns a greeting based on 24-hour time input
    /// @param _time Time in 24h format (e.g., 0830, 1705, 2210)
    /// @return Greeting string based on time
    function doNotDisturb(uint256 _time) external pure returns (string memory) {
        // Panic if invalid 24h time
        assert(_time < 2400);

        // Revert if before 08:00 or after 22:00
        if (_time < 800 || _time > 2200) {
            revert AfterHours(_time);
        }

        // Lunch break: 12:00–12:59
        if (_time >= 1200 && _time <= 1259) {
            revert("At lunch!");
        }

        // Morning: 08:00–11:59
        if (_time >= 800 && _time <= 1199) {
            return "Morning!";
        }

        // Afternoon: 13:00–17:59
        if (_time >= 1300 && _time <= 1799) {
            return "Afternoon!";
        }

        // Evening: 18:00–22:00
        if (_time >= 1800 && _time <= 2200) {
            return "Evening!";
        }

        // Catch-all: invalid minute ranges (e.g., 1260–1299)
        return "";
    }
}
