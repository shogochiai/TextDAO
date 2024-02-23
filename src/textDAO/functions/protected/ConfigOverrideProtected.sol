
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { ProtectionBase } from "~/_predicates/ProtectionBase.sol";
import { TallyForks } from "~/textDAO/functions/TallyForks.sol";

contract ConfigOverrideProtected is ProtectionBase {
    function setProposalsConfig(uint pid, StorageLib.ConfigOverride memory configOverride) public protected(pid) returns (bool) {
        StorageLib.ConfigOverrideStorage storage $configOverride = StorageLib.$ConfigOverride();
        $configOverride.overrides[TallyForks.tallyForks.selector].quorumScore = configOverride.quorumScore;
    }
}
