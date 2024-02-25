// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { StorageScheme } from "~/textDAO/storages/StorageScheme.sol";
import { StorageSlot } from "~/textDAO/storages/StorageSlot.sol";
import { SortLib } from "~/_predicates/SortLib.sol";
import { SelectorLib } from "~/_predicates/SelectorLib.sol";

contract Tally {
    function tally(uint pid) external onlyOncePerInterval(pid) returns (bool) {
        StorageScheme.ProposeStorage storage $ = StorageLib.$Proposals();
        StorageScheme.Proposal storage $p = $.proposals[pid];
        StorageScheme.Header[] storage $headers = $p.headers;
        StorageScheme.Command[] storage $cmds = $p.cmds;
        StorageScheme.ConfigOverrideStorage storage $configOverride = StorageLib.$ConfigOverride();

        StorageScheme.ProposalVars memory vars;

        require($p.proposalMeta.createdAt + $.config.expiryDuration > block.timestamp, "This proposal has been expired. You cannot run new tally to update ranks.");

        vars.headerRank = new uint[]($headers.length);
        vars.headerRank = SortLib.rankHeaders($headers, $p.proposalMeta.nextHeaderTallyFrom);
        vars.cmdRank = new uint[]($cmds.length);
        vars.cmdRank = SortLib.rankCmds($cmds, $p.proposalMeta.nextCmdTallyFrom);

        uint headerTopScore = $headers[vars.headerRank[0]].currentScore;
        bool headerCond = headerTopScore >= $.config.quorumScore;
        StorageScheme.Command storage $topCmd = $cmds[vars.cmdRank[0]];
        uint cmdTopScore = $topCmd.currentScore;


        // Note: Passing multiple actions requires unanymous achivement of all quorum including harder conditions.
        vars.cmdConds = new bool[]($topCmd.actions.length);
        vars.cmdCondSum;
        for (uint i; i < $topCmd.actions.length; i++) {
            StorageScheme.Action storage $action = $topCmd.actions[i];
            uint quorumOverride = $configOverride.overrides[SelectorLib.selector($action.func)].quorumScore;
            if (quorumOverride > 0) {
                vars.cmdConds[i] = cmdTopScore >= quorumOverride; // Special quorum
            } else {
                vars.cmdConds[i] = cmdTopScore >= $.config.quorumScore; // Global quorum
            }
            if (vars.cmdConds[i]) {
                vars.cmdCondSum = true;
            } else {
                vars.cmdCondSum = false;
                break;
            }
        }
        
        if ($p.proposalMeta.headerRank.length == 0) {
            $p.proposalMeta.headerRank = new uint[](3);
        }
        if (headerCond) {
            $p.proposalMeta.headerRank[0] = vars.headerRank[0];
            $p.proposalMeta.headerRank[1] = vars.headerRank[1];
            $p.proposalMeta.headerRank[2] = vars.headerRank[2];
            $p.proposalMeta.nextHeaderTallyFrom = $headers.length;
        } else {
            // emit HeaderQuorumFailed
        }

        if ($p.proposalMeta.cmdRank.length == 0) {
            $p.proposalMeta.cmdRank = new uint[](3);
        }
        if (vars.cmdCondSum) {
            $p.proposalMeta.cmdRank[0] = vars.cmdRank[0];
            $p.proposalMeta.cmdRank[1] = vars.cmdRank[1];
            $p.proposalMeta.cmdRank[2] = vars.cmdRank[2];
            $p.proposalMeta.nextCmdTallyFrom = $cmds.length;
        } else {
            // emit CommandQuorumFailed
        }

        // Repeatable tally
        for (uint i = 0; i < 3; ++i) {
            vars.headerRank2 = $p.proposalMeta.headerRank[i];
            vars.cmdRank2 = $p.proposalMeta.cmdRank[i];

            // Copy top ranked Headers and Commands to temporary arrays
            if(vars.headerRank2 < $p.headers.length){
                vars.topHeaders[i] = $p.headers[vars.headerRank2];
            }
            
            if(vars.cmdRank2 < $p.cmds.length){
                vars.topCommands[i] = $p.cmds[vars.cmdRank2];
            }
        }

        // Re-populate with top ranked items
        // next{Header,Cmd}TallyFrom effectively remains these top-3 elements
        for (uint i = 0; i < 3; ++i) {
            $p.headers[vars.headerRank2].id = vars.topHeaders[i].id;
            $p.headers[vars.headerRank2].currentScore = vars.topHeaders[i].currentScore;
            $p.headers[vars.headerRank2].metadataURI = vars.topHeaders[i].metadataURI;
            for (uint j; j < vars.topHeaders[i].tagIds.length; j++) {
                $p.headers[vars.headerRank2].tagIds[j] = vars.topHeaders[i].tagIds[j];
            }

            $p.cmds[vars.cmdRank2].id = vars.topCommands[i].id;
            for (uint j; j < vars.topCommands[i].actions.length; j++) {
                $p.cmds[vars.cmdRank2].actions[j].func = vars.topCommands[i].actions[j].func;
                $p.cmds[vars.cmdRank2].actions[j].abiParams = vars.topCommands[i].actions[j].abiParams;
            }
            $p.cmds[vars.cmdRank2].currentScore = vars.topCommands[i].currentScore;
        }

        // interval flag
        require($.config.tallyInterval > 0, "Set tally interval at config.");
        $p.tallied[block.timestamp / $.config.tallyInterval] = true;
    }

    modifier onlyOncePerInterval(uint pid) {
        StorageScheme.ProposeStorage storage $ = StorageLib.$Proposals();
        StorageScheme.Proposal storage $p = $.proposals[pid];
        require($.config.tallyInterval > 0, "Set tally interval at config.");
        require(!$p.tallied[block.timestamp / $.config.tallyInterval], "This interval is already tallied.");
        _;
    }
}
