// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Storage } from "~/textDAO/storages/Storage.sol";
import { Schema } from "~/textDAO/storages/Schema.sol";
import { Constants } from "~/_utils/Constants.sol";
import { ProtectionBase } from "~/_utils/ProtectionBase.sol";

contract MemberJoinProtected is ProtectionBase {
    function memberJoin(uint pid, Schema.Member[] memory candidates) public protected(pid) returns (bool) {
        Schema.MemberJoinProtectedStorage storage $ = Storage.$Members();

        for (uint i; i < candidates.length; i++) {
            $.members[$.nextMemberId+i].id = candidates[i].id;
            $.members[$.nextMemberId+i].addr = candidates[i].addr;
            $.members[$.nextMemberId+i].metadataURI = candidates[i].metadataURI;
        }
        $.nextMemberId = $.nextMemberId + candidates.length;
    }
}