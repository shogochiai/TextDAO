// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { console2 } from "forge-std/console2.sol";
import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";

contract Vote {
    function voteHeaders(uint pid, uint[3] calldata headerIds) external returns (bool) {
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];

        require($p.headers.length > 0, "No headers for this proposal.");

        if ($p.headers[0].id == headerIds[0]) {
            $p.headers[headerIds[0]].currentScore += 3;
        } else if ($p.headers[1].id == headerIds[0]) {
            $p.headers[headerIds[0]].currentScore += 3;
            $p.headers[headerIds[1]].currentScore += 2;
        } else {
            $p.headers[headerIds[0]].currentScore += 3;
            $p.headers[headerIds[1]].currentScore += 2;
            $p.headers[headerIds[2]].currentScore += 1;
        }
    }
    function voteCmds(uint pid, uint[3] calldata cmdIds) external returns (bool) {
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];

        require($p.cmds.length > 0, "No cmds for this proposal.");

        if ($p.cmds[0].id == cmdIds[0]) {
            $p.cmds[cmdIds[0]].currentScore += 3;
        } else if ($p.cmds[1].id == cmdIds[0]) {
            $p.cmds[cmdIds[0]].currentScore += 3;
            $p.cmds[cmdIds[1]].currentScore += 2;
        } else {
            $p.cmds[cmdIds[0]].currentScore += 3;
            $p.cmds[cmdIds[1]].currentScore += 2;
            $p.cmds[cmdIds[2]].currentScore += 1;
        }
    }
}
