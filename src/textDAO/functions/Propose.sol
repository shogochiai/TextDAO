// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { console2 } from "forge-std/console2.sol";
import { Storage } from "bundle/textdao/storages/Storage.sol";
import { Schema } from "bundle/textdao/storages/Schema.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract Propose {
    function propose(Schema.ProposalArg calldata _p) external onlyMember returns (uint proposalId) {
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[proposalId];
        Schema.VRFStorage storage $vrf = Storage.$VRF();
        Schema.MemberJoinProtectedStorage storage $member = Storage.$Members();

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
        Schema.VRFStorage storage $vrf = Storage.$VRF();
        Schema.Request storage $r = $vrf.requests[requestId];
        Schema.ProposeStorage storage $prop = Storage.$Proposals();
        Schema.Proposal storage $p = $prop.proposals[$r.proposalId];
        Schema.MemberJoinProtectedStorage storage $member = Storage.$Members();


        uint256[] memory randomWords = randomWordsReturned;

        for (uint i; i < randomWords.length; i++) {
            uint pickedIndex = uint256(randomWords[i]) % $member.nextMemberId;
            $p.proposalMeta.reps[$p.proposalMeta.nextRepId] = $member.members[pickedIndex].addr;
            $p.proposalMeta.nextRepId++;
        }
    }

    modifier onlyMember() {
        Schema.MemberJoinProtectedStorage storage $member = Storage.$Members();

        bool result;

        for (uint i; i < $member.nextMemberId; i++) {
            result = $member.members[i].addr == msg.sender || result;
        }
        require(result, "You are not the member.");
        _;
    }

}
