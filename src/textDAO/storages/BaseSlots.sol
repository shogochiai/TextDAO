// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * StorageSlot v0.1.0
 * keccak256(abi.encode(uint256(keccak256("<corresponded URL in the Schema.sol>")) - 1)) & ~bytes32(uint256(0xff));
 */


/// @custom:domain-a ProposeStorage
/// @custom:domain-b TextSaveProtectedStorage
/// @custom:domain-c MemberJoinProtectedStorage
/// @custom:domain-d VRFStorage
/// @custom:domain-e ConfigOverrideStorage
library BaseSlots {    
    bytes32 public constant baseslot_ProposeStorage =
        0x9a70c69f78b954ec2ace8c62308c5ea2ed35f782ee583f10b56d88886fa99300;
    bytes32 public constant baseslot_TextSaveProtectedStorage =
        0x00c2b62a56d6a36d26f9b1ee520f3f92694a04313c94e467f10a03b080d77900;
    bytes32 public constant baseslot_MemberJoinProtectedStorage =
        0x2909c0a05d58f8b7f14a4ef9b6dfbc139611bb545981c04988c895be90f35000;
    bytes32 public constant baseslot_VRFStorage =
        0xe4fa6871814422bfe1d10a118a3483c970f3cc6a461f81c9d5701005cfdaf400;
    bytes32 public constant baseslot_ConfigOverrideStorage =
        0x147a311fe1db87247fe76cc1e6db3134e5d52a59e0824f018dad572e05b14000;    
}