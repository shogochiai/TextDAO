// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "../internal/StorageLib.sol";
import { PassOpBase } from "./PassOpBase.sol";

contract MemberJoinPassOp is PassOpBase {
    function memberJoin(uint pid, StorageLib.Member[] memory candidates) public onlyPassed(pid) returns (bool) {
        StorageLib.MemberJoinPassOpStorage storage $ = StorageLib.$Members();

        for (uint i; i < candidates.length; i++) {
            $.members[$.nextMemberId+i].id = candidates[i].id;
            $.members[$.nextMemberId+i].addr = candidates[i].addr;
            $.members[$.nextMemberId+i].metadataURI = candidates[i].metadataURI;
        }
        $.nextMemberId = $.nextMemberId + candidates.length;
    }
}