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

    function $Proposals() internal pure returns (StorageScheme.ProposeStorage storage $) {
        bytes32 mem = StorageSlot.PROPOSALS_STORAGE_LOCATION;
        assembly { $.slot := mload(mem) }
    }

    function $Texts() internal pure returns (StorageScheme.TextSaveProtectedStorage storage $) {
        bytes32 mem = StorageSlot.TEXTS_STORAGE_LOCATION;
        assembly { $.slot := mload(mem) }
    }

    function $Members() internal pure returns (StorageScheme.MemberJoinProtectedStorage storage $) {
        bytes32 mem = StorageSlot.MEMBERS_STORAGE_LOCATION;
        assembly { $.slot := mload(mem) }
    }

    function $VRF() internal pure returns (StorageScheme.VRFStorage storage $) {
        bytes32 mem = StorageSlot.VRF_STORAGE_LOCATION;
        assembly { $.slot := mload(mem) }
    }

    function $ConfigOverride() internal pure returns (StorageScheme.ConfigOverrideStorage storage $) {
        bytes32 mem = StorageSlot.CONF_OVERRIDE_STORAGE_LOCATION;
        assembly { $.slot := mload(mem) }
    }    

}
