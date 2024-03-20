// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@chainlink/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import { Schema } from "bundle/textdao/storages/Schema.sol";
import { Constants } from "bundle/_utils/Constants.sol";

/**
 * StorageLib v0.1.0
 */
library Storage {
    bytes32 internal constant PROPOSALS_STORAGE_LOCATION = Constants.PROPOSALS_STORAGE_LOCATION;
    bytes32 internal constant TEXTS_STORAGE_LOCATION = Constants.TEXTS_STORAGE_LOCATION;
    bytes32 internal constant MEMBERS_STORAGE_LOCATION = Constants.MEMBERS_STORAGE_LOCATION;
    bytes32 internal constant VRF_STORAGE_LOCATION = Constants.VRF_STORAGE_LOCATION;
    bytes32 internal constant CONF_OVERRIDE_STORAGE_LOCATION = Constants.CONF_OVERRIDE_STORAGE_LOCATION;

    function $Proposals() internal pure returns (Schema.ProposeStorage storage $) {
        bytes32 slot = PROPOSALS_STORAGE_LOCATION;
        assembly { $.slot := slot }
    }

    function $Texts() internal pure returns (Schema.TextSaveProtectedStorage storage $) {
        bytes32 slot = TEXTS_STORAGE_LOCATION;
        assembly { $.slot := slot }
    }

    function $Members() internal pure returns (Schema.MemberJoinProtectedStorage storage $) {
        bytes32 slot = MEMBERS_STORAGE_LOCATION;
        assembly { $.slot := slot }
    }

    function $VRF() internal pure returns (Schema.VRFStorage storage $) {
        bytes32 slot = VRF_STORAGE_LOCATION;
        assembly { $.slot := slot }
    }

    function $ConfigOverride() internal pure returns (Schema.ConfigOverrideStorage storage $) {
        bytes32 slot = CONF_OVERRIDE_STORAGE_LOCATION;
        assembly { $.slot := slot }
    }
}