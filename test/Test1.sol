// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Test } from "forge-std/Test.sol";
import { UCSTestBase } from "lib/UCSTestBase.sol";
import { ProposeOp } from "src/ProposeOp.sol";
import { RCVForForksOp } from "src/RCVForForksOp.sol";
import { ExecuteProposalOp } from "src/ExecuteProposalOp.sol";
import { TallyForksOp } from "src/TallyForksOp.sol";
import { StorageLib } from "src/internal/StorageLib.sol";
import { TextSavePassOp } from "src/passop/TextSavePassOp.sol";

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
        p.header.metadataURI = "Qc.....xh";
        uint pid = ProposeOp(address(this)).propose(p);
        assertEq(pid, 0);
        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];
        assertEq($p.proposalMeta.headerRank.length, 0);
        assertEq($p.proposalMeta.cmdRank.length, 0);
        assertEq($p.headers[0].metadataURI, p.header.metadataURI);
    }

    function test_rcvHeaderForks() public {
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

        RCVForForksOp(address(this)).rcvForHeaderForks(pid, [fork1stId, fork2ndId, fork3rdId]);

        uint fork1stScoreAfter = $p.headers[fork1stId].currentScore;
        uint fork2ndScoreAfter = $p.headers[fork2ndId].currentScore;
        uint fork3rdScoreAfter = $p.headers[fork3rdId].currentScore;

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
        StorageLib.Command[] storage $cmds = $p.cmds;
        for (uint i; i < 10; i++) {
            $cmds.push();
        }

        uint fork1stScoreBefore = $p.cmds[fork1stId].currentScore;
        uint fork2ndScoreBefore = $p.cmds[fork2ndId].currentScore;
        uint fork3rdScoreBefore = $p.cmds[fork3rdId].currentScore;

        RCVForForksOp(address(this)).rcvForBodyForks(pid, [fork1stId, fork2ndId, fork3rdId]);

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

    function test_executeProposal_successWithText() public {
        uint pid = 0;
        uint textId = 0;
        bytes32 metadataURI1 = bytes32(uint256(1));
        bytes32 metadataURI2 = bytes32(uint256(2));
        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];
        StorageLib.Text storage $text = StorageLib.$Texts().texts[textId];

        $p.cmds.push(); // Note: initialize for storage array
        StorageLib.Command storage $cmd = $p.cmds[0];
        $cmd.id = 0;
        $cmd.actions.push(); // Note: initialize for storage array
        StorageLib.Action storage $action = $cmd.actions[0];

        $action.addr = address(new TextSavePassOp());
        $action.func = "textSave(uint256,uint256,bytes32[])";
        $action.abiParams = abi.encode(pid, textId, [metadataURI1, metadataURI1]);

        $p.proposalMeta.cmdRank.push(); // Note: initialize for storage array
        $p.proposalMeta.cmdRank[0] = $cmd.id;

        $p.proposalMeta.expireAt = 0;
        $p.proposalMeta.headerRank.push(); // Note: initialize for storage array

        assertEq($text.metadataURIs.length, 0);
        ExecuteProposalOp(address(this)).executeProposal(pid);
        assertGt($text.metadataURIs.length, 0);
    }


}
