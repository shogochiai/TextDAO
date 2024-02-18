// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Test } from "forge-std/Test.sol";
import { UCSTestBase } from "lib/UCSTestBase.sol";
import { ProposeOp } from "src/ProposeOp.sol";
import { RCVForForksOp } from "src/RCVForForksOp.sol";
import { ExecuteProposalOp } from "src/ExecuteProposalOp.sol";
import { TallyForksOp } from "src/TallyForksOp.sol";
import { StorageLib } from "src/internal/StorageLib.sol";

contract Test1 is UCSTestBase {

    function setUp() public override {
        implementations[ProposeOp.propose.selector] = address(new ProposeOp());
        implementations[ExecuteProposalOp.executeProposal.selector] = address(new ExecuteProposalOp());
        implementations[RCVForForksOp.rcvForHeaderForks.selector] = address(new RCVForForksOp());
        implementations[RCVForForksOp.rcvForBodyForks.selector] = address(new RCVForForksOp());
        implementations[TallyForksOp.tallyForks.selector] = address(new TallyForksOp());
    }


    function test_propose() public {
        StorageLib.ProposalArg memory p;
        p.headerFork.title = "This is a test proposal.";
        uint pid = ProposeOp(address(this)).propose(p);
        assertEq(pid, 0);
        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];
        assertEq($p.headerForks[$p.headerForksMeta.winningHeader1st].title, p.headerFork.title);
    }

    function test_rcvHeaderForks() public {
        uint pid = 0;
        uint fork1stId = 9;
        uint fork2ndId = 1;
        uint fork3rdId = 5;
        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];
        StorageLib.HeaderFork[] storage $hfs = $p.headerForks;
        for (uint i; i < 10; i++) {
            $hfs.push();
        }

        uint fork1stScoreBefore = $p.headerForks[fork1stId].currentScore;
        uint fork2ndScoreBefore = $p.headerForks[fork2ndId].currentScore;
        uint fork3rdScoreBefore = $p.headerForks[fork3rdId].currentScore;

        RCVForForksOp(address(this)).rcvForHeaderForks(pid, [fork1stId, fork2ndId, fork3rdId]);

        uint fork1stScoreAfter = $p.headerForks[fork1stId].currentScore;
        uint fork2ndScoreAfter = $p.headerForks[fork2ndId].currentScore;
        uint fork3rdScoreAfter = $p.headerForks[fork3rdId].currentScore;

        assertEq(fork1stScoreBefore + 3, fork1stScoreAfter);
        assertEq(fork2ndScoreBefore + 2, fork2ndScoreAfter);
        assertEq(fork3rdScoreBefore + 1, fork3rdScoreAfter);
    }
    function test_rcvForBodyForks() public {
        uint pid = 0;
        uint fork1stId = 7;
        uint fork2ndId = 6;
        uint fork3rdId = 5;
        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];
        StorageLib.BodyFork[] storage $bfs = $p.bodyForks;
        for (uint i; i < 10; i++) {
            $bfs.push();
        }

        uint fork1stScoreBefore = $p.bodyForks[fork1stId].currentScore;
        uint fork2ndScoreBefore = $p.bodyForks[fork2ndId].currentScore;
        uint fork3rdScoreBefore = $p.bodyForks[fork3rdId].currentScore;

        RCVForForksOp(address(this)).rcvForBodyForks(pid, [fork1stId, fork2ndId, fork3rdId]);

        uint fork1stScoreAfter = $p.bodyForks[fork1stId].currentScore;
        uint fork2ndScoreAfter = $p.bodyForks[fork2ndId].currentScore;
        uint fork3rdScoreAfter = $p.bodyForks[fork3rdId].currentScore;

        assertEq(fork1stScoreBefore + 3, fork1stScoreAfter);
        assertEq(fork2ndScoreBefore + 2, fork2ndScoreAfter);
        assertEq(fork3rdScoreBefore + 1, fork3rdScoreAfter);
    }

    function test_tallyForks_success() public {
        uint pid = 0;
        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];

        $p.proposalMeta.expireAt = block.timestamp + 1000;

        StorageLib.HeaderFork[] storage $hfs = $p.headerForks;
        StorageLib.BodyFork[] storage $bfs = $p.bodyForks;

        for (uint i; i < 10; i++) {
            $hfs.push();
            $bfs.push();
        }
        $bfs.push();

        $p.headerForksMeta.quorumScore = 8;
        $p.bodyForksMeta.quorumScore = 8;

        $p.headerForks[8].currentScore = 10;
        $p.headerForks[9].currentScore = 9;
        $p.headerForks[3].currentScore = 8;
        $p.bodyForks[4].currentScore = 10;
        $p.bodyForks[5].currentScore = 9;
        $p.bodyForks[6].currentScore = 8;

        TallyForksOp(address(this)).tallyForks(pid);

        assertEq($p.headerForksMeta.winningHeader1st, 8);
        assertEq($p.headerForksMeta.winningHeader2nd, 9);
        assertEq($p.headerForksMeta.winningHeader3rd, 3);
        assertEq($p.headerForksMeta.nextTallyFrom, 10);
        assertEq($p.bodyForksMeta.winningBody1st, 4);
        assertEq($p.bodyForksMeta.winningBody2nd, 5);
        assertEq($p.bodyForksMeta.winningBody3rd, 6);
        assertEq($p.bodyForksMeta.nextTallyFrom, 11);
    }

    function test_tallyForks_failWithExpired() public {
        uint pid = 0;
        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];

        $p.proposalMeta.expireAt = 0;

        StorageLib.HeaderFork[] storage $hfs = $p.headerForks;
        StorageLib.BodyFork[] storage $bfs = $p.bodyForks;

        for (uint i; i < 10; i++) {
            $hfs.push();
            $bfs.push();
        }
        $bfs.push();

        $p.headerForksMeta.quorumScore = 8;
        $p.bodyForksMeta.quorumScore = 8;

        $p.headerForks[8].currentScore = 10;
        $p.headerForks[9].currentScore = 9;
        $p.headerForks[3].currentScore = 8;
        $p.bodyForks[4].currentScore = 10;
        $p.bodyForks[5].currentScore = 9;
        $p.bodyForks[6].currentScore = 8;

        vm.expectRevert("This proposal has been expired. You cannot run new tally to update ranks.");
        TallyForksOp(address(this)).tallyForks(pid);

    }


    function test_executeProposal() public {
        uint pid = 0;
        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];
        $p.bodyForks.push();

        ExecuteProposalOp(address(this)).executeProposal(pid);
    }


}