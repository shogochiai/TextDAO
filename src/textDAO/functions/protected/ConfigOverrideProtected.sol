
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { StorageScheme } from "~/textDAO/storages/StorageScheme.sol";
import { StorageSlot } from "~/textDAO/storages/StorageSlot.sol";
import { ProtectionBase } from "~/_predicates/ProtectionBase.sol";
import { Tally } from "~/textDAO/functions/Tally.sol";

contract ConfigOverrideProtected is ProtectionBase {
    function setProposalsConfig(uint pid, StorageScheme.ConfigOverride memory configOverride) public protected(pid) returns (bool) {
        StorageScheme.ConfigOverrideStorage storage $configOverride = StorageLib.$ConfigOverride();
        $configOverride.overrides[Tally.tally.selector].quorumScore = configOverride.quorumScore;
    }
}
