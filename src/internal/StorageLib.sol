// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/**
 * StorageLib v0.1.0
 */
library StorageLib {    
    /*********************
     *  ProposeOpStorage
     ********************/
    /// @custom:storage-location erc7201:ucstest.proposeop.proposals
    struct ProposeOpStorage {
        mapping(uint => Proposal) proposals;
        uint nextProposalId;
        bool globalSuperImportantFlag;
    }
    struct ProposalArg {
        HeaderFork headerFork;
        BodyFork bodyFork;
        HeaderForksMeta headerForksMeta;
        BodyForksMeta bodyForksMeta;
        ProposalMeta proposalMeta;
    }
    struct Proposal {
        HeaderFork[] headerForks;
        BodyFork[] bodyForks;
        HeaderForksMeta headerForksMeta;
        BodyForksMeta bodyForksMeta;
        ProposalMeta proposalMeta;
    }
    struct HeaderFork {
        string title;
        uint currentScore;
    }
    struct BodyFork {
        string body;
        Command[] commands;
        uint currentScore;
    }
    struct Command {
        address target;
        bytes txbytes;
    }
    struct HeaderForksMeta {
        uint quorumScore;
        uint expireAt;
        uint winningHeader1st;
        uint winningHeader2nd;
        uint winningHeader3rd;
        uint nextTallyFrom;
    }
    struct BodyForksMeta {
        uint quorumScore;
        uint expireAt;
        uint winningBody1st;
        uint winningBody2nd;
        uint winningBody3rd;
        uint nextTallyFrom;
    }
    struct ProposalMeta {
        uint currentScore;
        uint quorumScore;
        uint expireAt;
    }

    // keccak256(abi.encode(uint256(keccak256("ucstest.proposeop.proposals")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant PROPOSALS_STORAGE_LOCATION =
        0x5807a52450ab8f738d6948632d619254c674252efb511a8ef74d8ec2510c9b00;

    function $Proposals() internal pure returns (ProposeOpStorage storage $) {
        assembly { $.slot := PROPOSALS_STORAGE_LOCATION }
    }

    /*********************
     *  DoubleOpStorage
     ********************/
    /// @custom:storage-location erc7201:ucstest.doubleop.doubles
    struct DoubleOpStorage {
        uint number;
    }

    // keccak256(abi.encode(uint256(keccak256("ucstest.doubleop.doubles")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant DOUBLE_STORAGE_LOCATION =
        0x028a2b90115601a2588b788693111cdb6f9f0f791eb66b87999400137d907c00;

    function $Doubles() internal pure returns (DoubleOpStorage storage $) {
        assembly { $.slot := DOUBLE_STORAGE_LOCATION }
    }

}
