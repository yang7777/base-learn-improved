// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ErrorTriageExercise {
    /**
     * 隣接する値同士の絶対差を返す: |a-b|, |b-c|, |c-d|
     */
    function diffWithNeighbors(
        uint _a,
        uint _b,
        uint _c,
        uint _d
    ) public pure returns (uint[] memory) {
        uint[] memory results = new uint[](3);
        results[0] = _a >= _b ? _a - _b : _b - _a;
        results[1] = _b >= _c ? _b - _c : _c - _b;
        results[2] = _c >= _d ? _c - _d : _d - _c;
        return results;
    }

    /**
     * _base (1000以上) に _modifier (-100〜+100) を加算して返す
     */
    function applyModifier(
        uint _base,
        int _modifier
    ) public pure returns (uint) {
        require(_base >= 1000, "base must be >= 1000");
        require(_modifier >= -100 && _modifier <= 100, "modifier out of range");

        int result = int(_base) + _modifier;
        require(result >= 0, "result underflow");

        return uint(result);
    }

    /**
     * 配列の末尾を取り出して返す（pop）
     */
    uint[] private arr;

    function popWithReturn() public returns (uint) {
        uint len = arr.length;
        require(len > 0, "array is empty");

        uint last = arr[len - 1];
        arr.pop();
        return last;
    }

    // ユーティリティ関数
    function addToArr(uint _num) public {
        arr.push(_num);
    }

    function getArr() public view returns (uint[] memory) {
        return arr;
    }

    function resetArr() public {
        delete arr;
    }
}
