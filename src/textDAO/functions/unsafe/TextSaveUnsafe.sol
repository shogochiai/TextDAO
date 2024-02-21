// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { UnsafeBase } from "~/_predicates/UnsafeBase.sol";

contract TextSaveUnsafe is UnsafeBase {
    function textSave(uint pid, uint textId, bytes32[] memory metadataURIs) public unsafe(pid) returns (bool) {
        StorageLib.TextSaveUnsafeStorage storage $ = StorageLib.$Texts();
        StorageLib.Text storage $text = $.texts[textId];
        $text.id = $.nextTextId;
        $text.metadataURIs = metadataURIs;
        $.nextTextId++;
    }
}