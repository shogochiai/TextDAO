// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { StorageLib } from "./StorageLib.sol";

contract BordaVoteForForksOp {
    function bordaVoteForHeaderForks(uint pid, uint[3] calldata fids) external returns (bool) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];
        
        $p.headerForks[fids[0]].currentScore += 3;
        $p.headerForks[fids[1]].currentScore += 2;
        $p.headerForks[fids[2]].currentScore += 1;
    }
    function bordaVoteForBodyForks(uint pid, uint[3] calldata fids) external returns (bool) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];

        $p.bodyForks[fids[0]].currentScore += 3;
        $p.bodyForks[fids[1]].currentScore += 2;
        $p.bodyForks[fids[2]].currentScore += 1;
    }
}
