// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { UCSTestBase } from "~/_predicates/UCSTestBase.sol";
import { Propose } from "~/textDAO/functions/Propose.sol";
import { Fork } from "~/textDAO/functions/Fork.sol";
import { Vote } from "~/textDAO/functions/Vote.sol";
import { ExecuteProposal } from "~/textDAO/functions/ExecuteProposal.sol";
import { TallyForks } from "~/textDAO/functions/TallyForks.sol";
import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract Test1 is UCSTestBase {

    function setUp() public override {
        implementations[Propose.propose.selector] = address(new Propose());
        implementations[Fork.fork.selector] = address(new Fork());
        implementations[ExecuteProposal.executeProposal.selector] = address(new ExecuteProposal());
        implementations[Vote.voteHeaders.selector] = address(new Vote());
        implementations[Vote.voteCmds.selector] = address(new Vote());
        implementations[TallyForks.tallyForks.selector] = address(new TallyForks());
    }


    function test_propose() public {
        StorageLib.MemberJoinUnsafeStorage storage $m = StorageLib.$Members();
        StorageLib.VRFStorage storage $vrf = StorageLib.$VRF();

        StorageLib.ProposalArg memory p;
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
        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];

        assertEq(pid, 0);
        assertEq($p.proposalMeta.headerRank.length, 0);
        assertEq($p.proposalMeta.cmdRank.length, 0);
        assertEq($p.headers[0].metadataURI, p.header.metadataURI);
    }

    function test_fork() public {
        uint pid = 0;
        StorageLib.ProposeStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];

        StorageLib.ProposalArg memory p;
        p.header.metadataURI = "Qc.....xh";
        p.cmd.actions = new StorageLib.Action[](1);

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
        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];
        StorageLib.Header[] storage $headers = $p.headers;
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
        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];
        StorageLib.Command[] storage $cmds = $p.cmds;
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

    function test_tallyForks_success() public {
        uint pid = 0;
        StorageLib.ProposeStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];

        $p.proposalMeta.createdAt = 0;
        $.config.expiryDuration = 1000;

        StorageLib.Header[] storage $headers = $p.headers;
        StorageLib.Command[] storage $cmds = $p.cmds;

        for (uint i; i < 10; i++) {
            $headers.push();
            $cmds.push();
        }
        $cmds.push();

        $.config.quorumScore = 8;

        $p.headers[8].currentScore = 10;
        $p.headers[9].currentScore = 9;
        $p.headers[3].currentScore = 8;
        $p.cmds[4].currentScore = 10;
        $p.cmds[5].currentScore = 9;
        $p.cmds[6].currentScore = 8;

        TallyForks(address(this)).tallyForks(pid);

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
        StorageLib.ProposeStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];

        $p.proposalMeta.createdAt = 0;
        $.config.expiryDuration = 0;

        StorageLib.Header[] storage $headers = $p.headers;
        StorageLib.Command[] storage $cmds = $p.cmds;

        for (uint i; i < 10; i++) {
            $headers.push();
            $cmds.push();
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
        TallyForks(address(this)).tallyForks(pid);

    }


    function test_executeProposal_success() public {
        uint pid = 0;
        StorageLib.Proposal storage $p = StorageLib.$Proposals().proposals[pid];
        $p.cmds.push();
        $p.proposalMeta.cmdRank = new uint[](3);

        ExecuteProposal(address(this)).executeProposal(pid);
    }

}
