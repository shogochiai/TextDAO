// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@chainlink/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { BaseSlots } from "bundle/textDAO/storages/BaseSlots.sol";

/**
 * StorageLib v0.1.0
 */
library Storage {
    bytes32 internal constant baseslot_ProposeStorage = BaseSlots.baseslot_ProposeStorage;
    bytes32 internal constant baseslot_TextSaveProtectedStorage = BaseSlots.baseslot_TextSaveProtectedStorage;
    bytes32 internal constant baseslot_MemberJoinProtectedStorage = BaseSlots.baseslot_MemberJoinProtectedStorage;
    bytes32 internal constant baseslot_VRFStorage = BaseSlots.baseslot_VRFStorage;
    bytes32 internal constant baseslot_ConfigOverrideStorage = BaseSlots.baseslot_ConfigOverrideStorage;

    function $Proposals() internal pure returns (Schema.ProposeStorage storage $) {
        bytes32 slot = baseslot_ProposeStorage;
        assembly { $.slot := slot }
    }

    function $Texts() internal pure returns (Schema.TextSaveProtectedStorage storage $) {
        bytes32 slot = baseslot_TextSaveProtectedStorage;
        assembly { $.slot := slot }
    }

    function $Members() internal pure returns (Schema.MemberJoinProtectedStorage storage $) {
        bytes32 slot = baseslot_MemberJoinProtectedStorage;
        assembly { $.slot := slot }
    }

    function $VRF() internal pure returns (Schema.VRFStorage storage $) {
        bytes32 slot = baseslot_VRFStorage;
        assembly { $.slot := slot }
    }

    function $ConfigOverride() internal pure returns (Schema.ConfigOverrideStorage storage $) {
        bytes32 slot = baseslot_ConfigOverrideStorage;
        assembly { $.slot := slot }
    }
}
