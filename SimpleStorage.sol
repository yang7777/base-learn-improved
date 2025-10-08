// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Custom error for exceeding maximum shares
error TooManyShares(uint256 wouldHave);

contract EmployeeStorage {
    // Storage packing: salary (32bit) + shares (16bit) = 48bit, 1 slot
    uint32 private salary;  // 0..1,000,000
    uint16 private shares;  // 0..5,000

    string public name;
    uint256 public idNumber;

    constructor(
        uint16 _shares,
        string memory _name,
        uint32 _salary,
        uint256 _idNumber
    ) {
        require(_shares <= 5000, "Initial shares too high");
        salary   = _salary;
        shares   = _shares;
        name     = _name;
        idNumber = _idNumber;
    }

    /// @notice Returns the current salary
    function viewSalary() external view returns (uint32) {
        return salary;
    }

    /// @notice Returns the current number of shares
    function viewShares() external view returns (uint16) {
        return shares;
    }

    /// @notice Grants additional shares to the employee
    /// @param _newShares Number of new shares to grant
    function grantShares(uint16 _newShares) external {
        uint256 newTotal = uint256(shares) + _newShares;
        if (newTotal > 5000) {
            revert TooManyShares(newTotal);
        }
        shares = uint16(newTotal);
    }

    /// @notice Returns raw storage slot value (for packing tests)
    function checkForPacking(uint256 _slot) external view returns (uint256 r) {
        assembly { r := sload(_slot) }
    }

    /// @notice Resets shares for testing purposes
    function debugResetShares() external {
        shares = 1000;
    }
}
