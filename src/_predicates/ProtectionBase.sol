// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { StorageScheme } from "~/textDAO/storages/StorageScheme.sol";
import { StorageSlot } from "~/textDAO/storages/StorageSlot.sol";

contract ProtectionBase {

    /// @dev Write your own reusable protection (e.g., for DAO, for AA wallets, for onlyOwner, for token holders and stakers)
    modifier protected(uint pid) {
        StorageScheme.ProposeStorage storage $ = StorageLib.$Proposals();
        StorageScheme.Proposal storage $p = $.proposals[pid];
        require($p.proposalMeta.createdAt + $.config.expiryDuration < block.timestamp && $p.proposalMeta.headerRank.length > 0, "Corresponding proposal must be expired and tallied.");
        _;
    }

}