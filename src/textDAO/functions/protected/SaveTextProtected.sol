// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Storage } from "bundle/textdao/storages/Storage.sol";
import { Schema } from "bundle/textdao/storages/Schema.sol";
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