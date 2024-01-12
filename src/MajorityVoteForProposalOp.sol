// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { StorageLib } from "./StorageLib.sol";

contract MajorityVoteForProposalOp {
    function majorityVoteForProposal(uint pid) external returns (bool) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        $.proposals[pid].proposalMeta.currentScore++;
    }
}
