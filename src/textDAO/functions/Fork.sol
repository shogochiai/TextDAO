// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { StorageScheme } from "~/textDAO/storages/StorageScheme.sol";
import { StorageSlot } from "~/textDAO/storages/StorageSlot.sol";

contract Fork {
    function fork(uint pid, StorageScheme.ProposalArg calldata _p) external onlyReps(pid) returns (uint forkId) {
        StorageScheme.ProposeStorage storage $ = StorageLib.$Proposals();
        StorageScheme.Proposal storage $p = $.proposals[pid];

        if (_p.header.metadataURI.length > 0) {
            $p.headers.push(_p.header);
        }
        if (_p.cmd.actions.length > 0) {
            $p.cmds.push(_p.cmd);
        }
        // Note: Shadow(sender, timestamp)
    }

    modifier onlyReps(uint pid) {
        StorageScheme.ProposeStorage storage $ = StorageLib.$Proposals();
        StorageScheme.Proposal storage $p = $.proposals[pid];

        bool result;
        for (uint i; i <  $p.proposalMeta.reps.length; i++) {
             result = $p.proposalMeta.reps[i] == msg.sender || result;
        }
        require(result, "You are not the rep.");
        _;
    }
}
