// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { StorageLib } from "./StorageLib.sol";

contract ProposeOp {
    function propose(StorageLib.Proposal calldata _proposal) external returns (uint proposalId) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        $.nextProposalId++;
        proposalId = $.nextProposalId;
        $.proposals[proposalId] = _proposal;
    }
}
