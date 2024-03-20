// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Storage } from "~/textDAO/storages/Storage.sol";
import { Schema } from "~/textDAO/storages/Schema.sol";
import { Constants } from "~/_utils/Constants.sol";

contract Fork {
    function fork(uint pid, Schema.ProposalArg calldata _p) external onlyReps(pid) returns (uint forkId) {
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];

        if (_p.header.metadataURI.length > 0) {
            $p.headers.push(_p.header);
        }
        if (_p.cmd.actions.length > 0) {
            $p.cmds.push(_p.cmd);
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
