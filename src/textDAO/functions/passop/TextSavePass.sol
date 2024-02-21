// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { PassOpBase } from "~/textDAO/functions/passop/PassOpBase.sol";

contract TextSavePass is PassOpBase {
    function textSave(uint pid, uint textId, bytes32[] memory metadataURIs) public onlyPassed(pid) returns (bool) {
        StorageLib.TextSavePassStorage storage $ = StorageLib.$Texts();
        StorageLib.Text storage $text = $.texts[textId];
        $text.id = $.nextTextId;
        $text.metadataURIs = metadataURIs;
        $.nextTextId++;
    }
}