// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { UCSTestBase } from "bundle/_utils/UCSTestBase.sol";
import { SelectorLib } from "bundle/_utils/SelectorLib.sol";
import { Propose } from "bundle/textDAO/functions/Propose.sol";
import { Fork } from "bundle/textDAO/functions/Fork.sol";
import { Vote } from "bundle/textDAO/functions/Vote.sol";
import { Execute } from "bundle/textDAO/functions/Execute.sol";
import { Tally } from "bundle/textDAO/functions/Tally.sol";
import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { Types } from "bundle/textDAO/storages/Types.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract Test1 is UCSTestBase {

    function setUp() public override {
        implementations[Propose.propose.selector] = address(new Propose());
        implementations[Fork.fork.selector] = address(new Fork());
        implementations[Execute.execute.selector] = address(new Execute());
        implementations[Vote.voteHeaders.selector] = address(new Vote());
        implementations[Vote.voteCmds.selector] = address(new Vote());
        implementations[Tally.tally.selector] = address(new Tally());
    }


    function test_propose() public {
        Schema.MemberJoinProtectedStorage storage $m = Storage.$Members();
        Schema.VRFStorage storage $vrf = Storage.$VRF();

        Types.ProposalArg memory p;
        p.header.metadataURI = "Qc.....xh";

        $vrf.config.vrfCoordinator = address(1);
        $vrf.subscriptionId = uint64(1);
        $vrf.config.keyHash = bytes32(uint256(1));
        $vrf.config.callbackGasLimit = uint32(1);
        $vrf.config.requestConfirmations = uint16(1);
        $vrf.config.numWords = uint32(1);
        $vrf.config.LINKTOKEN = address(1);
        vm.mockCall($vrf.config.vrfCoordinator, abi.encodeWithSelector(VRFCoordinatorV2Interface.requestRandomWords.selector), abi.encode(1));

        $m.nextMemberId = 1;
        $m.members[0].addr = address(this);

        uint pid = Propose(address(this)).propose(p);
        Schema.Proposal storage $p = Storage.$Proposals().proposals[pid];

        assertEq(pid, 0);
        assertEq($p.proposalMeta.headerRank.length, 0);
        assertEq($p.proposalMeta.cmdRank.length, 0);
        assertEq($p.headers[0].metadataURI, p.header.metadataURI);
    }

    function test_fork() public {
        uint pid = 0;
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];

        Types.ProposalArg memory p;
        p.header.metadataURI = "Qc.....xh";
        p.cmd.actions = new Schema.Action[](1);

        $p.proposalMeta.reps.push(); // array init
        $p.proposalMeta.reps[0] = address(this);

        assertEq($p.headers.length, 0);
        assertEq($p.cmds.length, 0);
        uint forkId = Fork(address(this)).fork(pid, p);
        assertEq($p.headers.length, 1);
        assertEq($p.cmds.length, 1);
    }
    function test_voteHeaders() public {
        uint pid = 0;
        uint fork1stId = 9;
        uint fork2ndId = 1;
        uint fork3rdId = 5;
        Schema.Proposal storage $p = Storage.$Proposals().proposals[pid];
        Schema.Header[] storage $headers = $p.headers;
        for (uint i; i < 10; i++) {
            $headers.push();
        }

        uint fork1stScoreBefore = $p.headers[fork1stId].currentScore;
        uint fork2ndScoreBefore = $p.headers[fork2ndId].currentScore;
        uint fork3rdScoreBefore = $p.headers[fork3rdId].currentScore;

        Vote(address(this)).voteHeaders(pid, [fork1stId, fork2ndId, fork3rdId]);

        uint fork1stScoreAfter = $p.headers[fork1stId].currentScore;
        uint fork2ndScoreAfter = $p.headers[fork2ndId].currentScore;
        uint fork3rdScoreAfter = $p.headers[fork3rdId].currentScore;

        assertEq(fork1stScoreBefore + 3, fork1stScoreAfter);
        assertEq(fork2ndScoreBefore + 2, fork2ndScoreAfter);
        assertEq(fork3rdScoreBefore + 1, fork3rdScoreAfter);
    }
    function test_voteCmds() public {
        uint pid = 0;
        uint fork1stId = 7;
        uint fork2ndId = 6;
        uint fork3rdId = 5;
        Schema.Proposal storage $p = Storage.$Proposals().proposals[pid];
        Schema.Command[] storage $cmds = $p.cmds;
        for (uint i; i < 10; i++) {
            $cmds.push();
        }

        uint fork1stScoreBefore = $p.cmds[fork1stId].currentScore;
        uint fork2ndScoreBefore = $p.cmds[fork2ndId].currentScore;
        uint fork3rdScoreBefore = $p.cmds[fork3rdId].currentScore;

        Vote(address(this)).voteCmds(pid, [fork1stId, fork2ndId, fork3rdId]);

        uint fork1stScoreAfter = $p.cmds[fork1stId].currentScore;
        uint fork2ndScoreAfter = $p.cmds[fork2ndId].currentScore;
        uint fork3rdScoreAfter = $p.cmds[fork3rdId].currentScore;

        assertEq(fork1stScoreBefore + 3, fork1stScoreAfter);
        assertEq(fork2ndScoreBefore + 2, fork2ndScoreAfter);
        assertEq(fork3rdScoreBefore + 1, fork3rdScoreAfter);
    }

    function test_tally_success() public {
        uint pid = 0;
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];

        $p.proposalMeta.createdAt = 0;
        $.config.expiryDuration = 1000;
        $.config.tallyInterval = 1000;

        Schema.Header[] storage $headers = $p.headers;
        Schema.Command[] storage $cmds = $p.cmds;

        for (uint i; i < 10; i++) {
            $headers.push();
            $cmds.push();
            $cmds[i].actions.push();
            Schema.Action storage $action = $cmds[i].actions[0];
            $action.func = "tally(uint256)";
        }
        $cmds.push();

        $.config.quorumScore = 8;

        $p.headers[8].currentScore = 10;
        $p.headers[9].currentScore = 9;
        $p.headers[3].currentScore = 8;
        $p.cmds[4].currentScore = 10;
        $p.cmds[5].currentScore = 9;
        $p.cmds[6].currentScore = 8;

        Tally(address(this)).tally(pid);

        assertEq($p.proposalMeta.headerRank[0], 8);
        assertEq($p.proposalMeta.headerRank[1], 9);
        assertEq($p.proposalMeta.headerRank[2], 3);
        assertEq($p.proposalMeta.nextHeaderTallyFrom, 10);
        assertEq($p.proposalMeta.cmdRank[0], 4);
        assertEq($p.proposalMeta.cmdRank[1], 5);
        assertEq($p.proposalMeta.cmdRank[2], 6);
        assertEq($p.proposalMeta.nextCmdTallyFrom, 11);
    }

    function test_tally_failCommandQuorumWithOverride() public {
        uint pid = 0;
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];
        Schema.ConfigOverrideStorage storage $configOverride = Storage.$ConfigOverride();

        $p.proposalMeta.createdAt = 0;
        $.config.expiryDuration = 1000;
        $.config.tallyInterval = 1000;

        Schema.Header[] storage $headers = $p.headers;
        Schema.Command[] storage $cmds = $p.cmds;

        for (uint i; i < 10; i++) {
            $headers.push();
            $cmds.push();
            $cmds[i].actions.push();
            Schema.Action storage $action = $cmds[i].actions[0];
            $action.func = "tally(uint256)";
        }
        $cmds.push();

        $.config.quorumScore = 8;
        $configOverride.overrides[Tally.tally.selector].quorumScore = 15;

        $p.headers[8].currentScore = 10;
        $p.headers[9].currentScore = 9;
        $p.headers[3].currentScore = 8;
        $p.cmds[4].currentScore = 10;
        $p.cmds[5].currentScore = 9;
        $p.cmds[6].currentScore = 8;

        Tally(address(this)).tally(pid);

        assertEq($p.proposalMeta.headerRank[0], 8);
        assertEq($p.proposalMeta.headerRank[1], 9);
        assertEq($p.proposalMeta.headerRank[2], 3);
        assertEq($p.proposalMeta.nextHeaderTallyFrom, 10);
        assertEq($p.proposalMeta.cmdRank[0], 0);
        assertEq($p.proposalMeta.cmdRank[1], 0);
        assertEq($p.proposalMeta.cmdRank[2], 0);
        assertEq($p.proposalMeta.nextCmdTallyFrom, 0);
    }


    function test_tally_failWithExpired() public {
        uint pid = 0;
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];

        $p.proposalMeta.createdAt = 0;
        $.config.expiryDuration = 0;
        $.config.tallyInterval = 1000;

        Schema.Header[] storage $headers = $p.headers;
        Schema.Command[] storage $cmds = $p.cmds;

        for (uint i; i < 10; i++) {
            $headers.push();
            $cmds.push();
            $cmds[i].actions.push();
            Schema.Action storage $action = $cmds[i].actions[0];
            $action.func = "tally(uint256)";
        }
        $cmds.push();

        $.config.quorumScore = 8;

        $p.headers[8].currentScore = 10;
        $p.headers[9].currentScore = 9;
        $p.headers[3].currentScore = 8;
        $p.cmds[4].currentScore = 10;
        $p.cmds[5].currentScore = 9;
        $p.cmds[6].currentScore = 8;

        vm.expectRevert("This proposal has been expired. You cannot run new tally to update ranks.");
        Tally(address(this)).tally(pid);

    }


    function test_execute_success() public {
        uint pid = 0;
        Schema.Proposal storage $p = Storage.$Proposals().proposals[pid];
        $p.cmds.push();
        $p.proposalMeta.cmdRank = new uint[](3);

        Execute(address(this)).execute(pid);
    }

}
