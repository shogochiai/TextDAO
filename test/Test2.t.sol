// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { UCSTestBase } from "bundle/_utils/UCSTestBase.sol";
import { Propose } from "bundle/textDAO/functions/Propose.sol";
import { Fork } from "bundle/textDAO/functions/Fork.sol";
import { Vote } from "bundle/textDAO/functions/Vote.sol";
import { Execute } from "bundle/textDAO/functions/Execute.sol";
import { Tally } from "bundle/textDAO/functions/Tally.sol";
import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { SaveTextProtected } from "bundle/textDAO/functions/protected/SaveTextProtected.sol";
import { MemberJoinProtected } from "bundle/textDAO/functions/protected/MemberJoinProtected.sol";

contract Test2 is UCSTestBase {

    function setUp() public override {
        implementations[Propose.propose.selector] = address(new Propose());
        implementations[Fork.fork.selector] = address(new Fork());
        implementations[Execute.execute.selector] = address(new Execute());
        implementations[Vote.voteHeaders.selector] = address(new Vote());
        implementations[Vote.voteCmds.selector] = address(new Vote());
        implementations[Tally.tally.selector] = address(new Tally());
        implementations[SaveTextProtected.saveText.selector] = address(new SaveTextProtected());
        implementations[MemberJoinProtected.memberJoin.selector] = address(new MemberJoinProtected());
    }

    function test_execute_successWithText() public {
        uint pid = 0;
        uint textId = 0;

        // Note: Array variable is only available as function args.
        bytes32[] memory metadataURIs = new bytes32[](2);
        metadataURIs[0] = bytes32(uint256(1));
        metadataURIs[1] = bytes32(uint256(2));

        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];

        Schema.Text storage $text = Storage.$Texts().texts[textId];

        $p.cmds.push(); // Note: initialize for storage array
        Schema.Command storage $cmd = $p.cmds[0];
        $cmd.id = 0;
        $cmd.actions.push(); // Note: initialize for storage array
        Schema.Action storage $action = $cmd.actions[0];

        $action.func = "saveText(uint256,uint256,bytes32[])";
        $action.abiParams = abi.encode(pid, textId, metadataURIs);

        $p.proposalMeta.cmdRank.push(); // Note: initialize for storage array
        $p.proposalMeta.cmdRank[0] = $cmd.id;

        $p.proposalMeta.createdAt = 0;
        $.config.expiryDuration = 0;
        $p.proposalMeta.headerRank.push(); // Note: initialize for storage array

        assertEq($text.metadataURIs.length, 0);
        Execute(address(this)).execute(pid);
        assertGt($text.metadataURIs.length, 0);
    }



    function test_execute_successWithJoin() public {
        uint pid = 0;

        Schema.Member[] memory candidates = new Schema.Member[](2);
        Schema.Member memory member1;
        member1.id = 0;
        member1.addr = address(1);
        candidates[0] = member1;
        Schema.Member memory member2;
        member2.id = 1;
        member2.addr = address(2);
        candidates[1] = member2;

        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];
        Schema.MemberJoinProtectedStorage storage $m = Storage.$Members();

        $p.cmds.push(); // Note: initialize for storage array
        Schema.Command storage $cmd = $p.cmds[0];
        $cmd.id = 0;
        $cmd.actions.push(); // Note: initialize for storage array
        Schema.Action storage $action = $cmd.actions[0];

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
        Execute(address(this)).execute(pid);
        assertEq($m.members[0].addr, address(1));
        assertEq($m.members[1].addr, address(2));
        assertEq($m.nextMemberId, candidates.length);
    }




}
