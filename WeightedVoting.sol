// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// OpenZeppelinライブラリ
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/utils/structs/EnumerableSet.sol";

/**
 * WeightedVoting
 * -----------------------
 * - claim(): 各アドレス1回のみ100トークンを請求可能
 * - createIssue(): トークン保有者のみが議題を作成可
 * - vote(): 保有トークン量に応じて投票
 * - getIssue(): 議題の詳細を返却（voters含む）
 */
contract WeightedVoting is ERC20 {
    using EnumerableSet for EnumerableSet.AddressSet;

    /* ========================= 定数 ========================= */
    uint256 public constant MAX_SUPPLY = 1_000_000;
    uint256 public constant CLAIM_AMOUNT = 100;

    /* ========================= エラー ========================= */
    error TokensAlreadyClaimed();
    error AllTokensClaimed();
    error NoTokensHeld();
    error QuorumTooHigh(uint256 proposed);
    error AlreadyVoted();
    error VotingClosed();
    error InvalidIssueId(uint256 id);

    /* ========================= 型定義 ========================= */
    enum Vote { AGAINST, FOR, ABSTAIN }

    struct Issue {
        EnumerableSet.AddressSet voters;
        string issueDesc;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 votesAbstain;
        uint256 totalVotes;
        uint256 quorum;
        bool passed;
        bool closed;
    }

    struct IssueData {
        address[] voters;
        string issueDesc;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 votesAbstain;
        uint256 totalVotes;
        uint256 quorum;
        bool passed;
        bool closed;
    }

    /* ========================= ストレージ ========================= */
    Issue[] private issues;
    mapping(address => bool) private hasClaimed;

    /* ========================= コンストラクタ ========================= */
    constructor() ERC20("Weighted Voting Token", "WVOTE") {
        // index 0 はダミーとして確保（テスト互換用）
        issues.push();
    }

    /* ========================= トークン請求 ========================= */
    function claim() external {
        if (hasClaimed[msg.sender]) revert TokensAlreadyClaimed();
        if (totalSupply() + CLAIM_AMOUNT > MAX_SUPPLY) revert AllTokensClaimed();

        hasClaimed[msg.sender] = true;
        _mint(msg.sender, CLAIM_AMOUNT);
    }

    /* ========================= 議題作成 ========================= */
    function createIssue(string calldata desc, uint256 quorum) external returns (uint256) {
        if (balanceOf(msg.sender) == 0) revert NoTokensHeld();
        if (quorum > totalSupply()) revert QuorumTooHigh(quorum);

        issues.push();
        uint256 idx = issues.length - 1;

        Issue storage isx = issues[idx];
        isx.issueDesc = desc;
        isx.quorum = quorum;

        return idx;
    }

    /* ========================= 議題情報取得 ========================= */
    function getIssue(uint256 _id) external view returns (IssueData memory) {
        if (_id == 0 || _id >= issues.length) revert InvalidIssueId(_id);

        Issue storage s = issues[_id];

        return IssueData({
            voters: s.voters.values(),
            issueDesc: s.issueDesc,
            votesFor: s.votesFor,
            votesAgainst: s.votesAgainst,
            votesAbstain: s.votesAbstain,
            totalVotes: s.totalVotes,
            quorum: s.quorum,
            passed: s.passed,
            closed: s.closed
        });
    }

    /* ========================= 投票 ========================= */
    function vote(uint256 _issueId, Vote v) external {
        if (_issueId == 0 || _issueId >= issues.length) revert InvalidIssueId(_issueId);

        Issue storage isx = issues[_issueId];
        if (isx.closed) revert VotingClosed();
        if (isx.voters.contains(msg.sender)) revert AlreadyVoted();

        uint256 power = balanceOf(msg.sender);
        if (power == 0) revert NoTokensHeld();

        // 投票記録
        isx.voters.add(msg.sender);

        if (v == Vote.FOR) {
            isx.votesFor += power;
        } else if (v == Vote.AGAINST) {
            isx.votesAgainst += power;
        } else {
            isx.votesAbstain += power;
        }
        isx.totalVotes += power;

        // クオーラム到達チェック
        if (isx.totalVotes >= isx.quorum) {
            isx.closed = true;
            if (isx.votesFor > isx.votesAgainst) {
                isx.passed = true;
            }
        }
    }

    /* ========================= ユーティリティ ========================= */
    /// @notice 現在の全Issue数を返す（index確認用）
    function issueCount() external view returns (uint256) {
        return issues.length - 1; // 0番はダミー
    }
}
