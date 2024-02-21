// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "~/textDAO/storages/StorageLib.sol";

contract PassOpBase {
    modifier onlyPassed(uint pid) {
        StorageLib.ProposeStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];
        require($p.proposalMeta.createdAt + $.config.expiryDuration < block.timestamp && $p.proposalMeta.headerRank.length > 0, "Corresponding proposal must be expired and tallied.");
        _;
    }
}