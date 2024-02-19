// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "./internal/StorageLib.sol";
import { DecodeErrorString } from "../lib/DecodeErrorString.sol";

contract ExecuteProposalOp {
    function executeProposal(uint pid) external returns (bool) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];

        require($p.proposalMeta.expireAt <= block.timestamp, "Proposal must be finished.");
        require($p.cmds.length > 0, "No body forks to execute.");
        require($p.proposalMeta.cmdRank.length > 0, "Tally must be done at least once.");

        StorageLib.Action[] storage $actions = $p.cmds[$p.proposalMeta.cmdRank[0]].actions;


        for (uint i; i < $actions.length; i++) {
            StorageLib.Action memory action = $actions[i];
            // Note: Is msg.value of this proxy consistent among all delegatecalls?
            (bool success, bytes memory data) = action.addr.delegatecall(bytes.concat(
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
