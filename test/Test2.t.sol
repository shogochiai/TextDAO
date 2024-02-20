// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { UCSTestBase } from "lib/UCSTestBase.sol";
import { ProposeOp } from "src/textDAO/ProposeOp.sol";
import { ForkOp } from "src/textDAO/ForkOp.sol";
import { VoteOp } from "src/textDAO/VoteOp.sol";
import { ExecuteProposalOp } from "src/textDAO/ExecuteProposalOp.sol";
import { TallyForksOp } from "src/textDAO/TallyForksOp.sol";
import { StorageLib } from "src/textDAO/internal/StorageLib.sol";
import { TextSavePassOp } from "src/textDAO/passop/TextSavePassOp.sol";
import { MemberJoinPassOp } from "src/textDAO/passop/MemberJoinPassOp.sol";

contract Test2 is UCSTestBase {

    function setUp() public override {
        implementations[ProposeOp.propose.selector] = address(new ProposeOp());
        implementations[ForkOp.fork.selector] = address(new ForkOp());
        implementations[ExecuteProposalOp.executeProposal.selector] = address(new ExecuteProposalOp());
        implementations[VoteOp.voteHeaders.selector] = address(new VoteOp());
        implementations[VoteOp.voteCmds.selector] = address(new VoteOp());
        implementations[TallyForksOp.tallyForks.selector] = address(new TallyForksOp());
    }

    function test_executeProposal_successWithText() public {
        uint pid = 0;
        uint textId = 0;

        // Note: Array variable is only available as function args. 
        bytes32[] memory metadataURIs = new bytes32[](2);
        metadataURIs[0] = bytes32(uint256(1));
        metadataURIs[1] = bytes32(uint256(2));

        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];
        StorageLib.Text storage $text = StorageLib.$Texts().texts[textId];

        $p.cmds.push(); // Note: initialize for storage array
        StorageLib.Command storage $cmd = $p.cmds[0];
        $cmd.id = 0;
        $cmd.actions.push(); // Note: initialize for storage array
        StorageLib.Action storage $action = $cmd.actions[0];

        $action.addr = address(new TextSavePassOp());
        $action.func = "textSave(uint256,uint256,bytes32[])";
        $action.abiParams = abi.encode(pid, textId, metadataURIs);

        $p.proposalMeta.cmdRank.push(); // Note: initialize for storage array
        $p.proposalMeta.cmdRank[0] = $cmd.id;

        $p.proposalMeta.expireAt = 0;
        $p.proposalMeta.headerRank.push(); // Note: initialize for storage array

        assertEq($text.metadataURIs.length, 0);
        ExecuteProposalOp(address(this)).executeProposal(pid);
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

        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];
        StorageLib.MemberJoinPassOpStorage storage $m = StorageLib.$Members();

        $p.cmds.push(); // Note: initialize for storage array
        StorageLib.Command storage $cmd = $p.cmds[0];
        $cmd.id = 0;
        $cmd.actions.push(); // Note: initialize for storage array
        StorageLib.Action storage $action = $cmd.actions[0];

        $action.addr = address(new MemberJoinPassOp());
        $action.func = "memberJoin(uint256,(uint256,address,bytes32)[])";
        $action.abiParams = abi.encode(pid, candidates);

        $p.proposalMeta.cmdRank.push(); // Note: initialize for storage array
        $p.proposalMeta.cmdRank[0] = $cmd.id;

        $p.proposalMeta.expireAt = 0;
        $p.proposalMeta.headerRank.push(); // Note: initialize for storage array

        assertEq($m.members[0].addr, address(0));
        assertEq($m.members[1].addr, address(0));
        assertEq($m.nextMemberId, 0);
        ExecuteProposalOp(address(this)).executeProposal(pid);
        assertEq($m.members[0].addr, address(1));
        assertEq($m.members[1].addr, address(2));
        assertEq($m.nextMemberId, candidates.length);
    }




}
