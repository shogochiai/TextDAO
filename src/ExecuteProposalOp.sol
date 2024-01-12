// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { StorageLib } from "./StorageLib.sol";

contract ExecuteProposalOp {
    function executeProposal(uint pid) external returns (bool) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];
        require($p.bodyForks.length > 0, "No body forks to execute.");
        StorageLib.Command[] storage $cmds = $p.bodyForks[$p.bodyForksMeta.winningBody1st].commands;

        if ($p.proposalMeta.scoringRule == StorageLib.ScoringRules.MajorityRule) {
          if ($p.proposalMeta.currentScore >= $p.proposalMeta.quorumScore) {
            for (uint i; i < $cmds.length; i++) {
              StorageLib.Command memory cmd = $cmds[i];
              // Hopefully, check whitelist of registered ops
              (bool result,) = cmd.target.call(cmd.txbytes);
              require(result);
            }
            $.globalSuperImportantFlag = true;
          } else {
            revert("Execution denied: Quorum of majority rule is not reached.");
          }
        } else if ($p.proposalMeta.scoringRule == StorageLib.ScoringRules.BordaCount) {
            for (uint i; i < $cmds.length; i++) {
              StorageLib.Command memory cmd = $cmds[i];
              (bool result,) = cmd.target.call(cmd.txbytes);
              require(result);
            }
            $.globalSuperImportantFlag = true;
        }
    }
}
