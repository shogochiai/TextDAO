// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { StorageScheme } from "~/textDAO/storages/StorageScheme.sol";
import { StorageSlot } from "~/textDAO/storages/StorageSlot.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract Propose {
    function propose(StorageScheme.ProposalArg calldata _p) external onlyMember returns (uint proposalId) {
        StorageScheme.ProposeStorage storage $ = StorageLib.$Proposals();
        StorageScheme.Proposal storage $p = $.proposals[proposalId];
        StorageScheme.VRFStorage storage $vrf = StorageLib.$VRF();
        StorageScheme.MemberJoinProtectedStorage storage $member = StorageLib.$Members();

        if ($.config.repsNum < $member.nextMemberId) {
            /*
                VRF Request to choose reps
            */

            require($vrf.subscriptionId > 0, "No Chainlink VRF subscription. Try SetConfigsProtected::createAndFundSubscription first.");
            require($vrf.config.vrfCoordinator != address(0), "No Chainlink VRF vrfCoordinator. Try SetVRFProtected::setVRFConfig first.");
            require($vrf.config.keyHash != 0, "No Chainlink VRF keyHash. Try SetConfigsProtected::setVRFConfig first.");
            require($vrf.config.callbackGasLimit != 0, "No Chainlink VRF callbackGasLimit. Try SetConfigsProtected::setVRFConfig first.");
            require($vrf.config.requestConfirmations != 0, "No Chainlink VRF requestConfirmations. Try SetConfigsProtected::setVRFConfig first.");
            require($vrf.config.numWords != 0, "No Chainlink VRF numWords. Try SetConfigsProtected::setVRFConfig first.");
            require($vrf.config.LINKTOKEN != address(0), "No Chainlink VRF LINKTOKEN. Try SetConfigs::setVRFConfig first.");


            // Assumes the subscription is funded sufficiently.
            uint256 requestId = VRFCoordinatorV2Interface($vrf.config.vrfCoordinator).requestRandomWords(
                $vrf.config.keyHash,
                $vrf.subscriptionId,
                $vrf.config.requestConfirmations,
                $vrf.config.callbackGasLimit,
                $vrf.config.numWords
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
        StorageScheme.VRFStorage storage $vrf = StorageLib.$VRF();
        StorageScheme.Request storage $r = $vrf.requests[requestId];
        StorageScheme.ProposeStorage storage $prop = StorageLib.$Proposals();
        StorageScheme.Proposal storage $p = $prop.proposals[$r.proposalId];
        StorageScheme.MemberJoinProtectedStorage storage $member = StorageLib.$Members();


        uint256[] memory randomWords = randomWordsReturned;

        for (uint i; i < randomWords.length; i++) {
            uint pickedIndex = uint256(randomWords[i]) % $member.nextMemberId;
            $p.proposalMeta.reps[$p.proposalMeta.nextRepId] = $member.members[pickedIndex].addr;
            $p.proposalMeta.nextRepId++;
        }
    }

    modifier onlyMember() {
        StorageScheme.MemberJoinProtectedStorage storage $member = StorageLib.$Members();

        bool result;

        for (uint i; i < $member.nextMemberId; i++) {
            result = $member.members[i].addr == msg.sender || result;
        }
        require(result, "You are not the member.");
        _;
    }

}
