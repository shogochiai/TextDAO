// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { StorageScheme } from "~/textDAO/storages/StorageScheme.sol";
import { StorageSlot } from "~/textDAO/storages/StorageSlot.sol";
import { ProtectionBase } from "~/_predicates/ProtectionBase.sol";

contract MemberJoinProtected is ProtectionBase {
    function memberJoin(uint pid, StorageScheme.Member[] memory candidates) public protected(pid) returns (bool) {
        StorageScheme.MemberJoinProtectedStorage storage $ = StorageLib.$Members();

        for (uint i; i < candidates.length; i++) {
            $.members[$.nextMemberId+i].id = candidates[i].id;
            $.members[$.nextMemberId+i].addr = candidates[i].addr;
            $.members[$.nextMemberId+i].metadataURI = candidates[i].metadataURI;
        }
        $.nextMemberId = $.nextMemberId + candidates.length;
    }
}