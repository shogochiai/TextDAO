// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Storage } from "bundle/textdao/storages/Storage.sol";
import { Schema } from "bundle/textdao/storages/Schema.sol";
import { Types } from "bundle/textdao/storages/Types.sol";

contract Fork {
    event HeaderForked(uint pid, Schema.Header header);
    event CommandForked(uint pid, Schema.Command cmd);

    function fork(uint pid, Types.ProposalArg calldata _p) external onlyReps(pid) returns (uint forkId) {
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];

        if (_p.header.metadataURI.length > 0) {
            $p.headers.push(_p.header);
            emit HeaderForked(pid, _p.header);
        }
        if (_p.cmd.actions.length > 0) {
            $p.cmds.push(_p.cmd);
            emit CommandForked(pid, _p.cmd);
        }
        // Note: Shadow(sender, timestamp)
    }

    modifier onlyReps(uint pid) {
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];

        bool result;
        for (uint i; i <  $p.proposalMeta.reps.length; i++) {
             result = $p.proposalMeta.reps[i] == msg.sender || result;
        }
        require(result, "You are not the rep.");
        _;
    }
}
