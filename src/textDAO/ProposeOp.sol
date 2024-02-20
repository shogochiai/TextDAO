// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "./internal/StorageLib.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract ProposeOp {
    function propose(StorageLib.ProposalArg calldata _p) external onlyMember returns (uint proposalId) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[proposalId];
        StorageLib.VRFStorage storage $vrf = StorageLib.$VRF();
        StorageLib.MemberJoinPassOpStorage storage $member = StorageLib.$Members();

        if ($p.proposalMeta.repsNum == 0) {
            $p.proposalMeta.repsNum = 30;
        }

        if ($p.proposalMeta.repsNum < $member.nextMemberId) {
            /*
                VRF Request to choose reps
            */

            require($vrf.subscriptionId > 0, "No Chainlink VRF subscription. Try SetVRFPassOp::createAndFundSubscription first.");

            if ($vrf.vrfCoordinator == address(0)) {
                $vrf.vrfCoordinator = address(30);
            }
            if ($vrf.keyHash == bytes32(0)) {
                $vrf.keyHash = bytes32(0);
            }
            if ($vrf.callbackGasLimit == uint32(0)) {
                $vrf.callbackGasLimit = uint32(2000000);
            }
            if ($vrf.requestConfirmations == uint16(0)) {
                $vrf.requestConfirmations = uint16(3);
            }
            if ($vrf.numWords == uint32(0)) {
                $vrf.numWords = uint32(30);
            }

            // Assumes the subscription is funded sufficiently.
            uint256 requestId = VRFCoordinatorV2Interface($vrf.vrfCoordinator).requestRandomWords(
                $vrf.keyHash,
                $vrf.subscriptionId,
                $vrf.requestConfirmations,
                $vrf.callbackGasLimit,
                $vrf.numWords
            );

            $vrf.requests[$vrf.nextId].requestId = requestId;
            $vrf.requests[$vrf.nextId].proposalId = proposalId;
            $vrf.nextId++;
        }

        if (_p.header.metadataURI.length > 0) {
            $p.headers.push(_p.header);
        }
        if (_p.cmd.actions.length > 0) {
            $p.cmds.push(_p.cmd);
        }
        // Note: Shadow(sender, timestamp)
        
        proposalId = $.nextProposalId;
        $.nextProposalId++;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWordsReturned) public returns (bool) {
        StorageLib.VRFStorage storage $vrf = StorageLib.$VRF();
        StorageLib.Request storage $r = $vrf.requests[requestId];
        StorageLib.ProposeOpStorage storage $prop = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $prop.proposals[$r.proposalId];
        StorageLib.MemberJoinPassOpStorage storage $member = StorageLib.$Members();


        uint256[] memory randomWords = randomWordsReturned;

        for (uint i; i < randomWords.length; i++) {
            uint pickedIndex = uint256(randomWords[i]) % $member.nextMemberId;
            $p.proposalMeta.reps[$p.proposalMeta.nextRepId] = $member.members[pickedIndex].addr;
            $p.proposalMeta.nextRepId++;
        }
    }

    modifier onlyMember() {
        StorageLib.MemberJoinPassOpStorage storage $member = StorageLib.$Members();

        bool result;

        for (uint i; i < $member.nextMemberId; i++) {
            result = $member.members[i].addr == msg.sender || result;
        }
        require(result, "You are not the member.");
        _;
    }

}
