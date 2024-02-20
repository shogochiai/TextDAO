// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "./internal/StorageLib.sol";

contract ProposeOp {
    function propose(StorageLib.ProposalArg calldata _p) external returns (uint proposalId) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[proposalId];

        if (_p.header.metadataURI.length > 0) {
            $p.headers.push(_p.header);
        }
        if (_p.cmd.actions.length > 0) {
            $p.cmds.push(_p.cmd);
        }
        // Note: Shadow(sender, timestamp)
        
        proposalId = $.nextProposalId;
        $.nextProposalId++;
    }
}
