
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { UnsafeBase } from "~/_predicates/UnsafeBase.sol";
import { TallyForks } from "~/textDAO/functions/TallyForks.sol";

contract ConfigOverrideUnsafe is UnsafeBase {
    function setProposalsConfig(uint pid, StorageLib.ConfigOverride memory configOverride) public unsafe(pid) returns (bool) {
        StorageLib.ConfigOverrideStorage storage $configOverride = StorageLib.$ConfigOverride();
        $configOverride.overrides[TallyForks.tallyForks.selector].quorumScore = configOverride.quorumScore;
    }
}
