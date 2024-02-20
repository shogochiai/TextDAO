// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "../internal/StorageLib.sol";

contract PassOpBase {
    modifier onlyPassed(uint pid) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];
        require($p.proposalMeta.expireAt < block.timestamp && $p.proposalMeta.headerRank.length > 0, "Corresponding proposal must be expired and tallied.");
        _;
    }
}