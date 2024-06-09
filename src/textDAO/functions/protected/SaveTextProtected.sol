// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Storage } from "bundle/textdao/storages/Storage.sol";
import { Schema } from "bundle/textdao/storages/Schema.sol";
import { ProtectionBase } from "bundle/_utils/ProtectionBase.sol";

contract SaveTextProtected is ProtectionBase {
    event TextSaved(uint pid, uint textId, bytes32[] metadataURIs);

    function saveText(uint pid, uint textId, bytes32[] memory metadataURIs) public protected(pid) returns (bool) {
        Schema.TextSaveProtectedStorage storage $ = Storage.$Texts();
        Schema.Text storage $text = $.texts[textId];
        $text.id = $.nextTextId;
        $text.metadataURIs = metadataURIs;
        $.nextTextId++;
        emit TextSaved(pid, $text.id, $text.metadataURIs);
    }
}