// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/**
 * StorageSlot v0.1.0
 */
library Constants {    
    // keccak256(abi.encode(uint256(keccak256("textDAO.PROPOSALS_STORAGE_LOCATION")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 public constant PROPOSALS_STORAGE_LOCATION =
        0xf1a4d8eab6724b783b75a5c8d6b4a5edac1afaa52adaa7d3c57201451ce8c400;

    // keccak256(abi.encode(uint256(keccak256("textDAO.TEXTS_STORAGE_LOCATION")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 public constant TEXTS_STORAGE_LOCATION =
        0x0a45678f7ac13226a0ead4e3b54db0ab263e1a30cc1ea3f19d7212aea5cd1d00;

    // keccak256(abi.encode(uint256(keccak256("textDAO.MEMBERS_STORAGE_LOCATION")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 public constant MEMBERS_STORAGE_LOCATION =
        0x2f8cab7d49dc616a0e8eb4e6f8b67d31c656445bf0c9ad5e38bc38d1128dcc00;

    // keccak256(abi.encode(uint256(keccak256("textDAO.VRF_STORAGE_LOCATION")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 public constant VRF_STORAGE_LOCATION =
        0x67f28ff67f7d7020f2b2ac7c9bd5f2a6dd9f19a9b15d92c4070c4572728ab000;

    // keccak256(abi.encode(uint256(keccak256("textDAO.CONF_OVERRIDE_STORAGE_LOCATION")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 public constant CONF_OVERRIDE_STORAGE_LOCATION =
        0x531151f4103280746205c56419d2c949e0976d9ee39d3c364618181eba5ee500;    

}
