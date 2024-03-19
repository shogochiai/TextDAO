// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@chainlink/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import { StorageScheme } from "~/textDAO/storages/StorageScheme.sol";
import { StorageSlot } from "~/textDAO/storages/StorageSlot.sol";

/**
 * StorageLib v0.1.0
 */
library StorageLib {
    bytes32 internal constant PROPOSALS_STORAGE_LOCATION = StorageSlot.PROPOSALS_STORAGE_LOCATION;
    bytes32 internal constant TEXTS_STORAGE_LOCATION = StorageSlot.TEXTS_STORAGE_LOCATION;
    bytes32 internal constant MEMBERS_STORAGE_LOCATION = StorageSlot.MEMBERS_STORAGE_LOCATION;
    bytes32 internal constant VRF_STORAGE_LOCATION = StorageSlot.VRF_STORAGE_LOCATION;
    bytes32 internal constant CONF_OVERRIDE_STORAGE_LOCATION = StorageSlot.CONF_OVERRIDE_STORAGE_LOCATION;

    function $Proposals() internal pure returns (StorageScheme.ProposeStorage storage $) {
        bytes32 slot = PROPOSALS_STORAGE_LOCATION;
        assembly { $.slot := slot }
    }

    function $Texts() internal pure returns (StorageScheme.TextSaveProtectedStorage storage $) {
        bytes32 slot = TEXTS_STORAGE_LOCATION;
        assembly { $.slot := slot }
    }

    function $Members() internal pure returns (StorageScheme.MemberJoinProtectedStorage storage $) {
        bytes32 slot = MEMBERS_STORAGE_LOCATION;
        assembly { $.slot := slot }
    }

    function $VRF() internal pure returns (StorageScheme.VRFStorage storage $) {
        bytes32 slot = VRF_STORAGE_LOCATION;
        assembly { $.slot := slot }
    }

    function $ConfigOverride() internal pure returns (StorageScheme.ConfigOverrideStorage storage $) {
        bytes32 slot = CONF_OVERRIDE_STORAGE_LOCATION;
        assembly { $.slot := slot }
    }
}