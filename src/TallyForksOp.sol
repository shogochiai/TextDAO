// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "./internal/StorageLib.sol";
import { SortLib } from "./internal/SortLib.sol";

contract TallyForksOp {
    function tallyForks(uint pid) external returns (bool) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];
        StorageLib.HeaderFork[] storage $hfs = $p.headerForks;
        StorageLib.BodyFork[] storage $bfs = $p.bodyForks;

        require($p.proposalMeta.expireAt > block.timestamp, "This proposal has been expired. You cannot run new tally to update ranks.");

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
