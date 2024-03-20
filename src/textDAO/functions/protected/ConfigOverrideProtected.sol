
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Storage } from "bundle/textdao/storages/Storage.sol";
import { Schema } from "bundle/textdao/storages/Schema.sol";
import { ProtectionBase } from "bundle/_utils/ProtectionBase.sol";
import { Tally } from "bundle/textdao/functions/Tally.sol";

contract ConfigOverrideProtected is ProtectionBase {
    function setProposalsConfig(uint pid, Schema.ConfigOverride memory configOverride) public protected(pid) returns (bool) {
        Schema.ConfigOverrideStorage storage $configOverride = Storage.$ConfigOverride();
        $configOverride.overrides[Tally.tally.selector].quorumScore = configOverride.quorumScore;
    }
}
