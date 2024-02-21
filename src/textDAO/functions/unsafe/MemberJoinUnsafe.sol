// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { UnsafeBase } from "~/_predicates/UnsafeBase.sol";

contract MemberJoinUnsafe is UnsafeBase {
    function memberJoin(uint pid, StorageLib.Member[] memory candidates) public unsafe(pid) returns (bool) {
        StorageLib.MemberJoinUnsafeStorage storage $ = StorageLib.$Members();

        for (uint i; i < candidates.length; i++) {
            $.members[$.nextMemberId+i].id = candidates[i].id;
            $.members[$.nextMemberId+i].addr = candidates[i].addr;
            $.members[$.nextMemberId+i].metadataURI = candidates[i].metadataURI;
        }
        $.nextMemberId = $.nextMemberId + candidates.length;
    }
}