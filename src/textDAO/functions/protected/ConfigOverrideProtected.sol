
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Storage } from "~/textDAO/storages/Storage.sol";
import { Schema } from "~/textDAO/storages/Schema.sol";
import { Constants } from "~/_utils/Constants.sol";
import { ProtectionBase } from "~/_utils/ProtectionBase.sol";
import { Tally } from "~/textDAO/functions/Tally.sol";

contract ConfigOverrideProtected is ProtectionBase {
    function setProposalsConfig(uint pid, Schema.ConfigOverride memory configOverride) public protected(pid) returns (bool) {
        Schema.ConfigOverrideStorage storage $configOverride = Storage.$ConfigOverride();
        $configOverride.overrides[Tally.tally.selector].quorumScore = configOverride.quorumScore;
    }
}
