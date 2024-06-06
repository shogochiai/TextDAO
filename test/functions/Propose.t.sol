// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2} from "@devkit/Flattened.sol";

import {Propose} from "bundle/textDAO/functions/Propose.sol";
import {Storage} from "bundle/textDAO/storages/Storage.sol";
import {Schema} from "bundle/textDAO/storages/Schema.sol";
import {Types} from "bundle/textDAO/storages/Types.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

/**
 *  Validation:
 *      - onlyMember
 *      - VRF Available
 *  State Diff:
 *      - $vrf.requests[$vrf.nextId]
 *          - requestId
 *          - proposalId
 *      - $vrf.nextId
 *      - $proposals[$---]
 *          - headers.push()
 *          - cmds.push()
 *      - nextProposalId
 */
contract ProposeTest is MCTest {

    struct StateDiff {
        uint256 vrfRequestId;
        uint256 vrfProposalId;
        uint256 vrfNextId;
        uint256 nextProposalId;
    }

    function setUp() public {
        _use(Propose.propose.selector, address(new Propose()));
    }

    // TODO
    // function test_propose_success_withoutVrfRequest() public {}

    function test_propose_success_withVrfRequest() public {
        Schema.MemberJoinProtectedStorage storage $m = Storage.$Members();
        Schema.VRFStorage storage $vrf = Storage.$VRF();

        $m.nextMemberId = 1;
        $m.members[0].addr = address(this);

        uint256 _requestId = 1;

        // TODO: use fixtures
        $vrf.subscriptionId = uint64(1);
        $vrf.config.vrfCoordinator = address(0xff);
        $vrf.config.keyHash = bytes32(uint256(1));
        $vrf.config.callbackGasLimit = uint32(1);
        $vrf.config.requestConfirmations = uint16(1);
        $vrf.config.numWords = uint32(1);
        $vrf.config.LINKTOKEN = address(1);
        vm.mockCall(
            $vrf.config.vrfCoordinator,
            abi.encodeWithSelector(VRFCoordinatorV2Interface.requestRandomWords.selector),
            abi.encode(_requestId)
        );

        Types.ProposalArg memory p;
        p.header.metadataURI = "Qc.....xh";

        vm.expectCall(
            $vrf.config.vrfCoordinator,
            abi.encodeCall(VRFCoordinatorV2Interface.requestRandomWords, (
                $vrf.config.keyHash,
                $vrf.subscriptionId,
                $vrf.config.requestConfirmations,
                $vrf.config.callbackGasLimit,
                $vrf.config.numWords
            )));

        // Store pre-state
        StateDiff memory _preState = StateDiff({
            vrfRequestId: $vrf.requests[$vrf.nextId].requestId,
            vrfProposalId: $vrf.requests[$vrf.nextId].proposalId,
            vrfNextId: $vrf.nextId,
            nextProposalId: Storage.$Proposals().nextProposalId
        });

        // Act & Record
        uint256 _proposedTime = block.timestamp;
        vm.record();
        uint256 pid = Propose(address(this)).propose(p);
        (, bytes32[] memory writes) = vm.accesses(address(this));

        assertEq(writes.length, 10);

        assertEq(_preState.vrfRequestId, 0);
        assertEq($vrf.requests[_preState.vrfRequestId].requestId, _requestId);
        assertEq($vrf.requests[_preState.vrfRequestId].proposalId, _preState.nextProposalId);
        assertEq(_preState.vrfNextId + 1, $vrf.nextId);

        Schema.Proposal storage $p = Storage.$Proposals().proposals[pid];

        assertEq(pid, 0);
        assertEq($p.proposalMeta.currentScore, 0);
        assertEq($p.proposalMeta.headerRank.length, 0);
        assertEq($p.proposalMeta.cmdRank.length, 0);
        assertEq($p.proposalMeta.nextHeaderTallyFrom, 0);
        assertEq($p.proposalMeta.nextCmdTallyFrom, 0);
        assertEq($p.proposalMeta.reps.length, 0);
        assertEq($p.proposalMeta.nextRepId, 0);
        assertEq($p.proposalMeta.createdAt, _proposedTime);
        assertEq($p.headers[0].metadataURI, p.header.metadataURI);
    }

    function test_propose_success_2nd() public {
        Schema.MemberJoinProtectedStorage storage $m = Storage.$Members();
        Schema.VRFStorage storage $vrf = Storage.$VRF();

        $m.nextMemberId = 1;
        $m.members[0].addr = address(this);

        uint256 _requestId = 1;

        // TODO: use fixtures
        $vrf.subscriptionId = uint64(1);
        $vrf.config.vrfCoordinator = address(0xff);
        $vrf.config.keyHash = bytes32(uint256(1));
        $vrf.config.callbackGasLimit = uint32(1);
        $vrf.config.requestConfirmations = uint16(1);
        $vrf.config.numWords = uint32(1);
        $vrf.config.LINKTOKEN = address(1);
        vm.mockCall(
            $vrf.config.vrfCoordinator,
            abi.encodeWithSelector(VRFCoordinatorV2Interface.requestRandomWords.selector),
            abi.encode(_requestId)
        );

        Types.ProposalArg memory p;
        p.header.metadataURI = "Qc.....xh";

        vm.expectCall(
            $vrf.config.vrfCoordinator,
            abi.encodeCall(VRFCoordinatorV2Interface.requestRandomWords, (
                $vrf.config.keyHash,
                $vrf.subscriptionId,
                $vrf.config.requestConfirmations,
                $vrf.config.callbackGasLimit,
                $vrf.config.numWords
            ))
        );

        // Store pre-state
        StateDiff memory _preState = StateDiff({
            vrfRequestId: $vrf.requests[$vrf.nextId].requestId,
            vrfProposalId: $vrf.requests[$vrf.nextId].proposalId,
            vrfNextId: $vrf.nextId,
            nextProposalId: Storage.$Proposals().nextProposalId
        });

        // Act & Record
        vm.record();
        uint pid = Propose(address(this)).propose(p);
        (, bytes32[] memory writes) = vm.accesses(address(this));

        assertEq(writes.length, 10);

        assertEq(_preState.vrfRequestId, 0);
        assertEq($vrf.requests[_preState.vrfRequestId].requestId, _requestId);
        assertEq($vrf.requests[_preState.vrfRequestId].proposalId, _preState.nextProposalId);
        assertEq(_preState.vrfNextId + 1, $vrf.nextId);

        Schema.Proposal storage $p = Storage.$Proposals().proposals[pid];

        assertEq(pid, 0);
        assertEq($p.proposalMeta.headerRank.length, 0);
        assertEq($p.proposalMeta.cmdRank.length, 0);
        assertEq($p.headers[0].metadataURI, p.header.metadataURI);

        uint pid2 = Propose(address(this)).propose(p);
        Schema.Proposal storage $p2 = Storage.$Proposals().proposals[pid2];

        assertEq(pid, 0);
        assertEq($p2.proposalMeta.headerRank.length, 0);
        assertEq($p2.proposalMeta.cmdRank.length, 0);
        assertEq($p2.headers[0].metadataURI, p.header.metadataURI);

    }

    function test_propose_RevertIf_NotMember() public {
        // Schema.MemberJoinProtectedStorage storage $m = Storage.$Members();
        // assertEq($m.members.length, 0);

        Types.ProposalArg memory p;

        vm.expectRevert("You are not the member.");
        Propose(address(this)).propose(p);
    }

}
