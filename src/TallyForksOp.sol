// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { StorageLib } from "./StorageLib.sol";
import { SortLib } from "./SortLib.sol";

contract TallyForksOp {
    function tallyForks(uint pid) external returns (bool) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];
        StorageLib.HeaderFork[] storage $hfs = $p.headerForks;
        StorageLib.BodyFork[] storage $bfs = $p.bodyForks;

        uint[] memory headerForksRanking = SortLib.rankHeaderForks($hfs);
        uint[] memory bodyForksRanking = SortLib.rankBodyForks($bfs);

        $p.headerForksMeta.winningHeader1st = headerForksRanking[0];
        $p.headerForksMeta.winningHeader2nd = headerForksRanking[1];
        $p.headerForksMeta.winningHeader3rd = headerForksRanking[2];
        $p.headerForksMeta.nextTallyFrom = $hfs.length;
        $p.bodyForksMeta.winningBody1st = bodyForksRanking[0];
        $p.bodyForksMeta.winningBody2nd = bodyForksRanking[1];
        $p.bodyForksMeta.winningBody3rd = bodyForksRanking[2];
        $p.bodyForksMeta.nextTallyFrom = $bfs.length;

    }
}
