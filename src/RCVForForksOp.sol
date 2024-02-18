// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "./internal/StorageLib.sol";
import { RCVLib } from "./internal/RCVLib.sol";

contract RCVForForksOp {
    function rcvForHeaderForks(uint pid, uint[3] calldata fids) external returns (bool) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];
        
        $p.headerForks[fids[0]].currentScore += 3;
        $p.headerForks[fids[1]].currentScore += 2;
        $p.headerForks[fids[2]].currentScore += 1;
    }
    function rcvForBodyForks(uint pid, uint[3] calldata fids) external returns (bool) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];

        $p.bodyForks[fids[0]].currentScore += 3;
        $p.bodyForks[fids[1]].currentScore += 2;
        $p.bodyForks[fids[2]].currentScore += 1;
    }
}
