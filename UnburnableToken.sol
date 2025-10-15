// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title UnburnableToken - 一度クレームしたら燃やせない無燃焼トークン
/// @author ChatGPT
/// @notice 学習用。1ウォレットにつき1000トークンを1回だけ無料請求可能。
contract UnburnableToken {
    /* ========== Errors ========== */
    error TokensAlreadyClaimed();
    error AllTokensClaimed();
    error UnsafeTransfer(address addr);
    error InsufficientBalance(uint256 have, uint256 want);
    error ZeroAmount();

    /* ========== Storage ========== */
    mapping(address => uint256) public balances;
    mapping(address => bool) private hasClaimed;

    uint256 public totalSupply;     // 固定: 100,000,000
    uint256 public totalClaimed;    // 累計配布済み数

    /* ========== Constants ========== */
    uint256 public constant CLAIM_AMOUNT = 1000;

    /* ========== Events ========== */
    event Claimed(address indexed who, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /* ========== Constructor ========== */
    constructor() {
        totalSupply = 100_000_000; // アンダースコア区切り可読化
    }

    /* ========== Claim ========== */
    /// @notice 各ウォレット1回だけ1000トークンを請求可能。
    function claim() external {
        if (hasClaimed[msg.sender]) revert TokensAlreadyClaimed();
        if (totalClaimed + CLAIM_AMOUNT > totalSupply) revert AllTokensClaimed();

        hasClaimed[msg.sender] = true;
        balances[msg.sender] += CLAIM_AMOUNT;
        totalClaimed += CLAIM_AMOUNT;

        emit Claimed(msg.sender, CLAIM_AMOUNT);
    }

    /// @notice 残り請求可能かどうか確認
    function canClaim(address user) external view returns (bool) {
        return (!hasClaimed[user] && totalClaimed + CLAIM_AMOUNT <= totalSupply);
    }

    /// @notice 未配布トークン数
    function remainingSupply() external view returns (uint256) {
        return totalSupply - totalClaimed;
    }

    /* ========== Safe Transfer ========== */
    /// @notice 0アドレス禁止 + 受取側にETH残高 > 0 必須
    function safeTransfer(address to, uint256 amount) external {
        if (to == address(0) || to.balance == 0) revert UnsafeTransfer(to);
        if (amount == 0) revert ZeroAmount();

        uint256 bal = balances[msg.sender];
        if (bal < amount) revert InsufficientBalance(bal, amount);

        unchecked {
            balances[msg.sender] = bal - amount;
            balances[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);
    }

    /* ========== Read-Only Views ========== */
    /// @notice 指定アドレスが既にクレーム済みか確認
    function hasAlreadyClaimed(address user) external view returns (bool) {
        return hasClaimed[user];
    }

    /* ========== Unburnable Proof ========== */
    /// @notice このトークンは burn 不可であることを明示
    function burn(uint256) external pure {
        revert("This token is unburnable");
    }
}
