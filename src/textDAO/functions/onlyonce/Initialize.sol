// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";

contract Initialize {
    function initialize(address[] calldata initialMembers, Schema.ProposalsConfig calldata pConfig) external onlyOnce returns (bool) {

        Schema.MemberJoinProtectedStorage storage $ = Storage.$Members();
        Schema.ProposalsConfig storage $pConfig = Storage.$Proposals().config;
        $pConfig.expiryDuration = pConfig.expiryDuration;
        $pConfig.tallyInterval = pConfig.tallyInterval;
        $pConfig.repsNum = pConfig.repsNum;
        $pConfig.quorumScore = pConfig.quorumScore;

        uint currentMemberId = $.nextMemberId;
        for (uint i = 0; i < initialMembers.length; i++) {
            $.members[currentMemberId].id = currentMemberId;
            $.members[currentMemberId].addr = initialMembers[i];
            $.members[currentMemberId].metadataURI = "";
            currentMemberId++;
        }
        $.nextMemberId = currentMemberId;
        return true;
    }
    modifier onlyOnce() {
        Schema.MemberJoinProtectedStorage storage $ = Storage.$Members();
        require($.nextMemberId == 0, "Initialize: already initialized");
        _;
    }

}
