// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { UCSTestBase } from "~/textDAO/_predicates/UCSTestBase.sol";
import { Propose } from "~/textDAO/functions/Propose.sol";
import { Fork } from "~/textDAO/functions/Fork.sol";
import { Vote } from "~/textDAO/functions/Vote.sol";
import { ExecuteProposal } from "~/textDAO/functions/ExecuteProposal.sol";
import { TallyForks } from "~/textDAO/functions/TallyForks.sol";
import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { TextSavePass } from "~/textDAO/functions/passop/TextSavePass.sol";
import { MemberJoinPass } from "~/textDAO/functions/passop/MemberJoinPass.sol";

contract Test2 is UCSTestBase {

    function setUp() public override {
        implementations[Propose.propose.selector] = address(new Propose());
        implementations[Fork.fork.selector] = address(new Fork());
        implementations[ExecuteProposal.executeProposal.selector] = address(new ExecuteProposal());
        implementations[Vote.voteHeaders.selector] = address(new Vote());
        implementations[Vote.voteCmds.selector] = address(new Vote());
        implementations[TallyForks.tallyForks.selector] = address(new TallyForks());
    }

    function test_executeProposal_successWithText() public {
        uint pid = 0;
        uint textId = 0;

        // Note: Array variable is only available as function args. 
        bytes32[] memory metadataURIs = new bytes32[](2);
        metadataURIs[0] = bytes32(uint256(1));
        metadataURIs[1] = bytes32(uint256(2));

        StorageLib.ProposeStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];

        StorageLib.Text storage $text = StorageLib.$Texts().texts[textId];

        $p.cmds.push(); // Note: initialize for storage array
        StorageLib.Command storage $cmd = $p.cmds[0];
        $cmd.id = 0;
        $cmd.actions.push(); // Note: initialize for storage array
        StorageLib.Action storage $action = $cmd.actions[0];

        $action.addr = address(new TextSavePass());
        $action.func = "textSave(uint256,uint256,bytes32[])";
        $action.abiParams = abi.encode(pid, textId, metadataURIs);

        $p.proposalMeta.cmdRank.push(); // Note: initialize for storage array
        $p.proposalMeta.cmdRank[0] = $cmd.id;

        $p.proposalMeta.createdAt = 0;
        $.config.expiryDuration = 0;
        $p.proposalMeta.headerRank.push(); // Note: initialize for storage array

        assertEq($text.metadataURIs.length, 0);
        ExecuteProposal(address(this)).executeProposal(pid);
        assertGt($text.metadataURIs.length, 0);
    }



    function test_executeProposal_successWithJoin() public {
        uint pid = 0;

        StorageLib.Member[] memory candidates = new StorageLib.Member[](2);
        StorageLib.Member memory member1;
        member1.id = 0;
        member1.addr = address(1);
        candidates[0] = member1;
        StorageLib.Member memory member2;
        member2.id = 1;
        member2.addr = address(2);
        candidates[1] = member2;

        StorageLib.ProposeStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];
        StorageLib.MemberJoinPassStorage storage $m = StorageLib.$Members();

        $p.cmds.push(); // Note: initialize for storage array
        StorageLib.Command storage $cmd = $p.cmds[0];
        $cmd.id = 0;
        $cmd.actions.push(); // Note: initialize for storage array
        StorageLib.Action storage $action = $cmd.actions[0];

        $action.addr = address(new MemberJoinPass());
        $action.func = "memberJoin(uint256,(uint256,address,bytes32)[])";
        $action.abiParams = abi.encode(pid, candidates);

        $p.proposalMeta.cmdRank.push(); // Note: initialize for storage array
        $p.proposalMeta.cmdRank[0] = $cmd.id;

        $p.proposalMeta.createdAt = 0;
        $.config.expiryDuration = 0;
        $p.proposalMeta.headerRank.push(); // Note: initialize for storage array

        assertEq($m.members[0].addr, address(0));
        assertEq($m.members[1].addr, address(0));
        assertEq($m.nextMemberId, 0);
        ExecuteProposal(address(this)).executeProposal(pid);
        assertEq($m.members[0].addr, address(1));
        assertEq($m.members[1].addr, address(2));
        assertEq($m.nextMemberId, candidates.length);
    }




}
