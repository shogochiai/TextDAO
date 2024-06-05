
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { ProtectionBase } from "bundle/_utils/ProtectionBase.sol";
import { Tally } from "bundle/textDAO/functions/Tally.sol";

contract ConfigOverrideProtected is ProtectionBase {
    function overrideProposalsConfig(uint pid, Schema.ConfigOverride memory configOverride) public protected(pid) returns (bool) {
        Schema.ConfigOverrideStorage storage $configOverride = Storage.$ConfigOverride();
        $configOverride.overrides[Tally.tally.selector].quorumScore = configOverride.quorumScore;
    }
}
