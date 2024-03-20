// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Storage } from "~/textDAO/storages/Storage.sol";
import { Schema } from "~/textDAO/storages/Schema.sol";
import { Constants } from "~/_utils/Constants.sol";

contract Vote {
    function voteHeaders(uint pid, uint[3] calldata headerIds) external returns (bool) {
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];
        
        $p.headers[headerIds[0]].currentScore += 3;
        $p.headers[headerIds[1]].currentScore += 2;
        $p.headers[headerIds[2]].currentScore += 1;
    }
    function voteCmds(uint pid, uint[3] calldata cmdIds) external returns (bool) {
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];

        $p.cmds[cmdIds[0]].currentScore += 3;
        $p.cmds[cmdIds[1]].currentScore += 2;
        $p.cmds[cmdIds[2]].currentScore += 1;
    }
}
