// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "./internal/StorageLib.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract ProposeOp {
    function propose(StorageLib.ProposalArg calldata _p) external onlyMember returns (uint proposalId) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[proposalId];

        if (_p.header.metadataURI.length > 0) {
            $p.headers.push(_p.header);
        }
        if (_p.cmd.actions.length > 0) {
            $p.cmds.push(_p.cmd);
        }
        // Note: Shadow(sender, timestamp)
        
        proposalId = $.nextProposalId;
        $.nextProposalId++;



        /*
            VRF Request to choose reps
        */
        uint64 s_subscriptionId = uint64(0);
        address vrfCoordinator = address(0);
        bytes32 keyHash = bytes32(0);
        uint32 callbackGasLimit = uint32(2000000);
        uint16 requestConfirmations = uint16(6);
        uint32 numWords =  uint32(30);

        // Assumes the subscription is funded sufficiently.
        uint256 requestId = VRFCoordinatorV2Interface(vrfCoordinator).requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        StorageLib.VRFStorage storage $vrf = StorageLib.$VRF();
        $vrf.requests[$vrf.nextId].requestId = requestId;
        $vrf.requests[$vrf.nextId].proposalId = proposalId;
        $vrf.nextId++;
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
        for (uint i; i <  $member.nextMemberId; i++) {
             result = $member.members[i].addr == msg.sender || result;
        }
        require(result, "You are not the member.");
        _;
    }

}
