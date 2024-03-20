// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Storage } from "~/textDAO/storages/Storage.sol";
import { Schema } from "~/textDAO/storages/Schema.sol";
import { Constants } from "~/_utils/Constants.sol";

contract ProtectionBase {

    /// @dev Write your own reusable protection (e.g., for DAO, for AA wallets, for onlyOwner, for token holders and stakers)
    modifier protected(uint pid) {
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];
        require($p.proposalMeta.createdAt + $.config.expiryDuration < block.timestamp && $p.proposalMeta.headerRank.length > 0, "Corresponding proposal must be expired and tallied.");
        _;
    }

}