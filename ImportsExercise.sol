// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./SillyStringUtils.sol";

contract ImportsExercise {
    using SillyStringUtils for string;

    // 公開インスタンス（自動 getter はメンバー単位だが、型ごと返す getter も作成）
    SillyStringUtils.Haiku public haiku;

    /// @notice 3行の Haiku を保存
    function saveHaiku(
        string memory line1,
        string memory line2,
        string memory line3
    ) public {
        haiku = SillyStringUtils.Haiku({ line1: line1, line2: line2, line3: line3 });
    }

    /// @notice Haiku 型そのものを返す getter
    function getHaiku() public view returns (SillyStringUtils.Haiku memory) {
        return haiku;
    }

    /// @notice line3 の末尾に 🤷 を付けた *新しい* Haiku を返す（元データは変更しない）
    function shruggieHaiku() public view returns (SillyStringUtils.Haiku memory) {
        return SillyStringUtils.Haiku({
            line1: haiku.line1,
            line2: haiku.line2,
            line3: SillyStringUtils.shruggie(haiku.line3) // 外部ライブラリ関数を直接呼び出す
        });
    }
}
