// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "./internal/StorageLib.sol";

contract ForkOp {
    function fork(uint pid, StorageLib.ProposalArg calldata _p) external returns (uint forkId) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];

        if (_p.header.metadataURI.length > 0) {
            $p.headers.push(_p.header);
        }
        if (_p.cmd.actions.length > 0) {
            $p.cmds.push(_p.cmd);
        }
        // Note: Shadow(sender, timestamp)
    }
}
