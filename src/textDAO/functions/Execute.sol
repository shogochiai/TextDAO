// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { StorageScheme } from "~/textDAO/storages/StorageScheme.sol";
import { StorageSlot } from "~/textDAO/storages/StorageSlot.sol";
import { DecodeErrorString } from "~/_predicates/DecodeErrorString.sol";

contract Execute {
    function execute(uint pid) external returns (bool) {
        StorageScheme.ProposeStorage storage $ = StorageLib.$Proposals();
        StorageScheme.Proposal storage $p = $.proposals[pid];

        require($p.proposalMeta.createdAt + $.config.expiryDuration <= block.timestamp, "Proposal must be finished.");
        require($p.cmds.length > 0, "No body forks to execute.");
        require($p.proposalMeta.cmdRank.length > 0, "Tally must be done at least once.");

        StorageScheme.Action[] storage $actions = $p.cmds[$p.proposalMeta.cmdRank[0]].actions;


        for (uint i; i < $actions.length; i++) {
            StorageScheme.Action memory action = $actions[i];
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
