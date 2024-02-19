// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "../internal/StorageLib.sol";

contract TextSavePassOp {
    function textSave(uint pid, uint textId, bytes32[] memory metadataURIs) public onlyPassed(pid) {
        StorageLib.TextSavePassOpStorage storage $ = StorageLib.$Texts();
        StorageLib.Text storage $text = $.texts[textId];
        $text.id = $.nextTextId;
        $text.metadataURIs = metadataURIs;
        $.nextTextId++;
    }
    modifier onlyPassed(uint pid) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];
        require($p.proposalMeta.expireAt < block.timestamp && $p.proposalMeta.headerRank.length > 0, "Corresponding proposal must be expired and tallied.");
        _;
    }
}