// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { SortLib } from "~/_predicates/SortLib.sol";
import { SelectorLib } from "~/_predicates/SelectorLib.sol";
import { console2 } from "forge-std/console2.sol";

contract TallyForks {
    function tallyForks(uint pid) external returns (bool) {
        StorageLib.ProposeStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];
        StorageLib.Header[] storage $headers = $p.headers;
        StorageLib.Command[] storage $cmds = $p.cmds;
        StorageLib.ConfigOverrideStorage storage $configOverride = StorageLib.$ConfigOverride();

        require($p.proposalMeta.createdAt + $.config.expiryDuration > block.timestamp, "This proposal has been expired. You cannot run new tally to update ranks.");

        uint[] memory headerRank = new uint[]($headers.length);
        headerRank = SortLib.rankHeaders($headers);
        uint[] memory cmdRank = new uint[]($cmds.length);
        cmdRank = SortLib.rankCmds($cmds);

        uint headerTopScore = $headers[headerRank[0]].currentScore;
        bool headerCond = headerTopScore >= $.config.quorumScore;
        StorageLib.Command storage $topCmd = $cmds[cmdRank[0]];
        uint cmdTopScore = $topCmd.currentScore;


        // Note: Passing multiple actions requires unanymous achivement of all quorum including harder conditions.
        bool[] memory cmdConds = new bool[]($topCmd.actions.length);
        bool cmdCondSum;
        for (uint i; i < $topCmd.actions.length; i++) {
            StorageLib.Action storage $action = $topCmd.actions[i];
            uint quorumOverride = $configOverride.overrides[SelectorLib.selector($action.func)].quorumScore;
            if (quorumOverride > 0) {
                cmdConds[i] = cmdTopScore >= quorumOverride; // Special quorum
            } else {
                cmdConds[i] = cmdTopScore >= $.config.quorumScore; // Global quorum
            }
            if (cmdConds[i]) {
                cmdCondSum = true;
            } else {
                cmdCondSum = false;
                break;
            }
        }
        
        if ($p.proposalMeta.headerRank.length == 0) {
            $p.proposalMeta.headerRank = new uint[](3);
        }
        if (headerCond) {
            $p.proposalMeta.headerRank[0] = headerRank[0];
            $p.proposalMeta.headerRank[1] = headerRank[1];
            $p.proposalMeta.headerRank[2] = headerRank[2];
            $p.proposalMeta.nextHeaderTallyFrom = $headers.length;
        } else {
            // emit HeaderQuorumFailed
        }

        if ($p.proposalMeta.cmdRank.length == 0) {
            $p.proposalMeta.cmdRank = new uint[](3);
        }
        if (cmdCondSum) {
            $p.proposalMeta.cmdRank[0] = cmdRank[0];
            $p.proposalMeta.cmdRank[1] = cmdRank[1];
            $p.proposalMeta.cmdRank[2] = cmdRank[2];
            $p.proposalMeta.nextCmdTallyFrom = $cmds.length;
        } else {
            // emit CommandQuorumFailed
        }

        // TODO: Reset headers and cmds for next session

    }
}
