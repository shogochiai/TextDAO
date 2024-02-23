
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { ProtectionBase } from "~/_predicates/ProtectionBase.sol";
import { Tally } from "~/textDAO/functions/Tally.sol";

contract ConfigOverrideProtected is ProtectionBase {
    function setProposalsConfig(uint pid, StorageLib.ConfigOverride memory configOverride) public protected(pid) returns (bool) {
        StorageLib.ConfigOverrideStorage storage $configOverride = StorageLib.$ConfigOverride();
        $configOverride.overrides[Tally.tally.selector].quorumScore = configOverride.quorumScore;
    }
}
