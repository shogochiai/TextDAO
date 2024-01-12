// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { StorageLib } from "./StorageLib.sol";

contract ProposeOp {
    function propose(StorageLib.ProposalArg calldata _p) external returns (uint proposalId) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[proposalId];
        $p.headerForks.push(_p.headerFork);
        $p.bodyForks.push(_p.bodyFork);
        $p.proposalMeta = _p.proposalMeta;
        $p.headerForksMeta.winningHeader1st = proposalId;
        $p.bodyForksMeta.winningBody1st = proposalId;

        proposalId = $.nextProposalId;
        $.nextProposalId++;
    }
}
