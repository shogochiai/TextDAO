// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { ProtectionBase } from "bundle/_utils/ProtectionBase.sol";

contract SaveTextProtected is ProtectionBase {
    function saveText(uint pid, uint textId, bytes32[] memory metadataURIs) public protected(pid) returns (bool) {
        Schema.TextSaveProtectedStorage storage $ = Storage.$Texts();
        Schema.Text storage $text = $.texts[textId];
        $text.id = $.nextTextId;
        $text.metadataURIs = metadataURIs;
        $.nextTextId++;
    }
}
