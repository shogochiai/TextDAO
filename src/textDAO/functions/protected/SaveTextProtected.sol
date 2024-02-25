// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { StorageScheme } from "~/textDAO/storages/StorageScheme.sol";
import { StorageSlot } from "~/textDAO/storages/StorageSlot.sol";
import { ProtectionBase } from "~/_predicates/ProtectionBase.sol";

contract SaveTextProtected is ProtectionBase {
    function saveText(uint pid, uint textId, bytes32[] memory metadataURIs) public protected(pid) returns (bool) {
        StorageScheme.TextSaveProtectedStorage storage $ = StorageLib.$Texts();
        StorageScheme.Text storage $text = $.texts[textId];
        $text.id = $.nextTextId;
        $text.metadataURIs = metadataURIs;
        $.nextTextId++;
    }
}