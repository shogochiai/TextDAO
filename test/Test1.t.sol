// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Test } from "forge-std/Test.sol";
import { UCSTestBase } from "lib/UCSTestBase.sol";
import { ProposeOp } from "src/textDAO/ProposeOp.sol";
import { ForkOp } from "src/textDAO/ForkOp.sol";
import { RCVForForksOp } from "src/textDAO/RCVForForksOp.sol";
import { ExecuteProposalOp } from "src/textDAO/ExecuteProposalOp.sol";
import { TallyForksOp } from "src/textDAO/TallyForksOp.sol";
import { StorageLib } from "src/textDAO/internal/StorageLib.sol";

contract Test1 is UCSTestBase {

    function setUp() public override {
        implementations[ProposeOp.propose.selector] = address(new ProposeOp());
        implementations[ForkOp.fork.selector] = address(new ForkOp());
        implementations[ExecuteProposalOp.executeProposal.selector] = address(new ExecuteProposalOp());
        implementations[RCVForForksOp.voteHeaders.selector] = address(new RCVForForksOp());
        implementations[RCVForForksOp.voteCmds.selector] = address(new RCVForForksOp());
        implementations[TallyForksOp.tallyForks.selector] = address(new TallyForksOp());
    }


    function test_propose() public {
        StorageLib.ProposalArg memory p;
        p.header.metadataURI = "Qc.....xh";
        uint pid = ProposeOp(address(this)).propose(p);
        assertEq(pid, 0);
        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];
        assertEq($p.proposalMeta.headerRank.length, 0);
        assertEq($p.proposalMeta.cmdRank.length, 0);
        assertEq($p.headers[0].metadataURI, p.header.metadataURI);
    }

    function test_fork() public {
        uint pid = 0;
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];

        StorageLib.ProposalArg memory p;
        p.header.metadataURI = "Qc.....xh";
        p.cmd.actions = new StorageLib.Action[](1);

        assertEq($p.headers.length, 0);
        assertEq($p.cmds.length, 0);
        uint forkId = ForkOp(address(this)).fork(pid, p);
        assertEq($p.headers.length, 1);
        assertEq($p.cmds.length, 1);
    }
    function test_voteHeaders() public {
        uint pid = 0;
        uint fork1stId = 9;
        uint fork2ndId = 1;
        uint fork3rdId = 5;
        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];
        StorageLib.Header[] storage $headers = $p.headers;
        for (uint i; i < 10; i++) {
            $headers.push();
        }

        uint fork1stScoreBefore = $p.headers[fork1stId].currentScore;
        uint fork2ndScoreBefore = $p.headers[fork2ndId].currentScore;
        uint fork3rdScoreBefore = $p.headers[fork3rdId].currentScore;

        RCVForForksOp(address(this)).voteHeaders(pid, [fork1stId, fork2ndId, fork3rdId]);

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
        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];
        StorageLib.Command[] storage $cmds = $p.cmds;
        for (uint i; i < 10; i++) {
            $cmds.push();
        }

        uint fork1stScoreBefore = $p.cmds[fork1stId].currentScore;
        uint fork2ndScoreBefore = $p.cmds[fork2ndId].currentScore;
        uint fork3rdScoreBefore = $p.cmds[fork3rdId].currentScore;

        RCVForForksOp(address(this)).voteCmds(pid, [fork1stId, fork2ndId, fork3rdId]);

        uint fork1stScoreAfter = $p.cmds[fork1stId].currentScore;
        uint fork2ndScoreAfter = $p.cmds[fork2ndId].currentScore;
        uint fork3rdScoreAfter = $p.cmds[fork3rdId].currentScore;

        assertEq(fork1stScoreBefore + 3, fork1stScoreAfter);
        assertEq(fork2ndScoreBefore + 2, fork2ndScoreAfter);
        assertEq(fork3rdScoreBefore + 1, fork3rdScoreAfter);
    }

    function test_tallyForks_success() public {
        uint pid = 0;
        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];

        $p.proposalMeta.expireAt = block.timestamp + 1000;

        StorageLib.Header[] storage $headers = $p.headers;
        StorageLib.Command[] storage $cmds = $p.cmds;

        for (uint i; i < 10; i++) {
            $headers.push();
            $cmds.push();
        }
        $cmds.push();

        $p.proposalMeta.quorumScore = 8;
        $p.proposalMeta.quorumScore = 8;

        $p.headers[8].currentScore = 10;
        $p.headers[9].currentScore = 9;
        $p.headers[3].currentScore = 8;
        $p.cmds[4].currentScore = 10;
        $p.cmds[5].currentScore = 9;
        $p.cmds[6].currentScore = 8;

        TallyForksOp(address(this)).tallyForks(pid);

        assertEq($p.proposalMeta.headerRank[0], 8);
        assertEq($p.proposalMeta.headerRank[1], 9);
        assertEq($p.proposalMeta.headerRank[2], 3);
        assertEq($p.proposalMeta.nextHeaderTallyFrom, 10);
        assertEq($p.proposalMeta.cmdRank[0], 4);
        assertEq($p.proposalMeta.cmdRank[1], 5);
        assertEq($p.proposalMeta.cmdRank[2], 6);
        assertEq($p.proposalMeta.nextCmdTallyFrom, 11);
    }

    function test_tallyForks_failWithExpired() public {
        uint pid = 0;
        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];

        $p.proposalMeta.expireAt = 0;

        StorageLib.Header[] storage $headers = $p.headers;
        StorageLib.Command[] storage $cmds = $p.cmds;

        for (uint i; i < 10; i++) {
            $headers.push();
            $cmds.push();
        }
        $cmds.push();

        $p.proposalMeta.quorumScore = 8;
        $p.proposalMeta.quorumScore = 8;

        $p.headers[8].currentScore = 10;
        $p.headers[9].currentScore = 9;
        $p.headers[3].currentScore = 8;
        $p.cmds[4].currentScore = 10;
        $p.cmds[5].currentScore = 9;
        $p.cmds[6].currentScore = 8;

        vm.expectRevert("This proposal has been expired. You cannot run new tally to update ranks.");
        TallyForksOp(address(this)).tallyForks(pid);

    }


    function test_executeProposal_success() public {
        uint pid = 0;
        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];
        $p.cmds.push();
        $p.proposalMeta.cmdRank = new uint[](3);

        ExecuteProposalOp(address(this)).executeProposal(pid);
    }

}
