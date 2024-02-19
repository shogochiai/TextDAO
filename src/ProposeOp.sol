// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "./internal/StorageLib.sol";

contract ProposeOp {
    function propose(StorageLib.ProposalArg calldata _p) external returns (uint proposalId) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[proposalId];
        $p.headers.push(_p.header);
        $p.cmds.push(_p.cmd);
        
        proposalId = $.nextProposalId;
        $.nextProposalId++;
    }
}
