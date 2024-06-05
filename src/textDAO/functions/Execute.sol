// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { DecodeErrorString } from "bundle/_utils/DecodeErrorString.sol";

contract Execute {
    function execute(uint pid) external returns (bool) {
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];

        require($p.proposalMeta.createdAt + $.config.expiryDuration <= block.timestamp, "Proposal must be finished.");
        require($p.cmds.length > 0, "No body forks to execute.");
        require($p.proposalMeta.cmdRank.length > 0, "Tally must be done at least once.");

        Schema.Action[] storage $actions = $p.cmds[$p.proposalMeta.cmdRank[0]].actions;


        for (uint i; i < $actions.length; i++) {
            Schema.Action memory action = $actions[i];
            // Note: Is msg.value of this proxy consistent among all delegatecalls?
            (bool success, bytes memory data) = address(this).delegatecall(bytes.concat(
                bytes4(keccak256(bytes(action.func))),
                action.abiParams
            ));

            if (success) {
            } else {
                revert(DecodeErrorString.decodeRevertReasonAndPanicCode(data));
            }
        }
    }
}
