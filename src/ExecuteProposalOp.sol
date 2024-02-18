// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "./internal/StorageLib.sol";

contract ExecuteProposalOp {
    function executeProposal(uint pid) external returns (bool) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];

        require($p.proposalMeta.expireAt <= block.timestamp, "Proposal must be finished.");
        require($p.cmds.length > 0, "No body forks to execute.");

        StorageLib.Action[] storage $actions = $p.cmds[$p.proposalMeta.cmdRank[0]].actions;

        for (uint i; i < $actions.length; i++) {
            StorageLib.Action memory action = $actions[i];
            (bool result,) = action.addr.call(bytes.concat(
                bytes4(keccak256(bytes(action.func))),
                action.abiParams
            ));
            require(result);
        }
    }
}
