// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { RCVLib } from "~/_predicates/RCVLib.sol";

contract Vote {
    function voteHeaders(uint pid, uint[3] calldata headerIds) external returns (bool) {
        StorageLib.ProposeStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];
        
        $p.headers[headerIds[0]].currentScore += 3;
        $p.headers[headerIds[1]].currentScore += 2;
        $p.headers[headerIds[2]].currentScore += 1;
    }
    function voteCmds(uint pid, uint[3] calldata cmdIds) external returns (bool) {
        StorageLib.ProposeStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];

        $p.cmds[cmdIds[0]].currentScore += 3;
        $p.cmds[cmdIds[1]].currentScore += 2;
        $p.cmds[cmdIds[2]].currentScore += 1;
    }
}
