// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "./internal/StorageLib.sol";

contract ExecuteProposalOp {
    function executeProposal(uint pid) external returns (bool) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];

        require($p.proposalMeta.expireAt <= block.timestamp, "Proposal must be finished.");
        require($p.bodyForks.length > 0, "No body forks to execute.");

        StorageLib.Command[] storage $cmds = $p.bodyForks[$p.bodyForksMeta.winningBody1st].commands;

        for (uint i; i < $cmds.length; i++) {
            StorageLib.Command memory cmd = $cmds[i];
            (bool result,) = cmd.target.call(cmd.txbytes);
            require(result);
        }
    }
}
