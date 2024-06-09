// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Storage } from "bundle/textdao/storages/Storage.sol";
import { Schema } from "bundle/textdao/storages/Schema.sol";
import { Types } from "bundle/textdao/storages/Types.sol";

contract Fork {
    event HeaderForked(uint pid, uint headerId, uint currentScore, bytes32 metadataURI, uint[] tagIds);
    event CommandForked(uint pid, uint cmdId, uint currentScore, string func, bytes abiParams);

    function fork(uint pid, Types.ProposalArg calldata _p) external onlyReps(pid) returns (uint forkId) {
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];

        if (_p.header.metadataURI.length > 0) {
            $p.headers.push(_p.header);
        }
        if (_p.cmd.actions.length > 0) {
            $p.cmds.push(_p.cmd);
        }
        if (_p.header.metadataURI.length > 0) {
            emit HeaderForked(pid, _p.header.id, _p.header.currentScore, _p.header.metadataURI, _p.header.tagIds);
        }
        if (_p.cmd.actions.length > 0) {
            for (uint i; i < _p.cmd.actions.length; i++) {
                emit CommandProposed(pid, _p.cmd.id, _p.cmd.currentScore, _p.cmd.actions[i].func, _p.cmd.actions[i].abiParams);
            }
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
