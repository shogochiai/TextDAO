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
        Header header;
        Command cmd;
        ProposalMeta proposalMeta;
    }
    struct Proposal {
        Header[] headers;
        Command[] cmds;
        ProposalMeta proposalMeta;
    }
    struct Header {
        uint id;
        uint currentScore;
        bytes32 metadataURI;
        uint[] tagIds;
    }
    struct Tag {
        uint id;
        bytes32 metadataURI;
    }
    struct Command {
        uint id;
        Action[] actions;
        uint currentScore;
    }
    struct Action {
        address addr;
        string func;
        bytes abiParams;
    }
    struct ProposalMeta {
        uint currentScore;
        uint quorumScore;
        uint expireAt;
        uint[] headerRank;
        uint[] cmdRank;
        uint nextHeaderTallyFrom;
        uint nextCmdTallyFrom;
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
