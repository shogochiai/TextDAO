// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { console2 } from "forge-std/console2.sol";
import { Storage } from "bundle/textdao/storages/Storage.sol";
import { Schema } from "bundle/textdao/storages/Schema.sol";

contract Vote {
    event HeaderScored(uint pid, uint headerId, uint currentScore);
    event CmdScored(uint pid, uint cmdId, uint currentScore);

    function voteHeaders(uint pid, uint[3] calldata headerIds) external returns (bool) {
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];

        require($p.headers.length > 0, "No headers for this proposal.");

        if ($p.headers[0].id == headerIds[0]) {
            $p.headers[headerIds[0]].currentScore += 3;
            emit HeaderScored(pid, headerIds[0], $p.headers[headerIds[0]].currentScore);
        } else if ($p.headers[1].id == headerIds[0]) {
            $p.headers[headerIds[0]].currentScore += 3;
            $p.headers[headerIds[1]].currentScore += 2;
            emit HeaderScored(pid, headerIds[0], $p.headers[headerIds[0]].currentScore);
            emit HeaderScored(pid, headerIds[1], $p.headers[headerIds[1]].currentScore);
        } else {
            $p.headers[headerIds[0]].currentScore += 3;
            $p.headers[headerIds[1]].currentScore += 2;
            $p.headers[headerIds[2]].currentScore += 1;
            emit HeaderScored(pid, headerIds[0], $p.headers[headerIds[0]].currentScore);
            emit HeaderScored(pid, headerIds[1], $p.headers[headerIds[1]].currentScore);
            emit HeaderScored(pid, headerIds[2], $p.headers[headerIds[2]].currentScore);
        }
    }
    function voteCmds(uint pid, uint[3] calldata cmdIds) external returns (bool) {
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];

        require($p.cmds.length > 0, "No cmds for this proposal.");

        if ($p.cmds[0].id == cmdIds[0]) {
            $p.cmds[cmdIds[0]].currentScore += 3;
            emit CmdScored(pid, cmdIds[0], $p.cmds[cmdIds[0]].currentScore);
        } else if ($p.cmds[1].id == cmdIds[0]) {
            $p.cmds[cmdIds[0]].currentScore += 3;
            $p.cmds[cmdIds[1]].currentScore += 2;
            emit CmdScored(pid, cmdIds[0], $p.cmds[cmdIds[0]].currentScore);
            emit CmdScored(pid, cmdIds[1], $p.cmds[cmdIds[1]].currentScore);
        } else {
            $p.cmds[cmdIds[0]].currentScore += 3;
            $p.cmds[cmdIds[1]].currentScore += 2;
            $p.cmds[cmdIds[2]].currentScore += 1;
            emit CmdScored(pid, cmdIds[0], $p.cmds[cmdIds[0]].currentScore);
            emit CmdScored(pid, cmdIds[1], $p.cmds[cmdIds[1]].currentScore);
            emit CmdScored(pid, cmdIds[2], $p.cmds[cmdIds[2]].currentScore);
        }
    }
}
