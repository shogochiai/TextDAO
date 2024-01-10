// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";
import { console2 } from "forge-std/console2.sol";


contract ProposeOp {
    /// @custom:storage-location erc7201:ucstest.proposeop.proposals
    struct ProposeOpStorage {
        mapping(uint => string) proposals;
        uint nextProposalId;
    }

    // keccak256(abi.encode(uint256(keccak256("ucstest.proposeop.proposals")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant PROPOSALS_STORAGE_LOCATION =
        0x5807a52450ab8f738d6948632d619254c674252efb511a8ef74d8ec2510c9b00;

    function _getStorage() private pure returns (ProposeOpStorage storage $) {
        assembly {
            $.slot := PROPOSALS_STORAGE_LOCATION
        }
    }

    function propose(string calldata _proposalText) external returns (uint proposalId) {
        ProposeOpStorage storage $ = _getStorage();
        $.nextProposalId++;
        proposalId = $.nextProposalId;
        $.proposals[proposalId] = _proposalText;
    }
}