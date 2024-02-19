// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "../internal/StorageLib.sol";
import { PassOpBase } from "./PassOpBase.sol";

contract TextSavePassOp is PassOpBase {
    function textSave(uint pid, uint textId, bytes32[] memory metadataURIs) public onlyPassed(pid) returns (bool) {
        StorageLib.TextSavePassOpStorage storage $ = StorageLib.$Texts();
        StorageLib.Text storage $text = $.texts[textId];
        $text.id = $.nextTextId;
        $text.metadataURIs = metadataURIs;
        $.nextTextId++;
    }
}