// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/**
 * StorageLib v0.1.0
 */
library StorageLib {    
    /*********************
     *  ProposeOpStorage
     ********************/
    /// @custom:storage-location erc7201:textDAO.proposeop.proposals
    struct ProposeOpStorage {
        mapping(uint => Proposal) proposals;
        uint nextProposalId;
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

    // keccak256(abi.encode(uint256(keccak256("textDAO.proposeop.proposals")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant PROPOSALS_STORAGE_LOCATION =
        0xd43a2afe07b94a8ce70d10f193569d2c070c983eb6cea4616d25510ca5dae200;

    function $Proposals() internal pure returns (ProposeOpStorage storage $) {
        assembly { $.slot := PROPOSALS_STORAGE_LOCATION }
    }



    /*********************
     *  TextSavePassOp Storage
     ********************/
    /// @custom:storage-location erc7201:textDAO.textSavePassOp.texts
    struct TextSavePassOpStorage {
        mapping(uint => Text) texts;
        uint nextTextId;
    }
    struct Text {
        uint id;
        bytes32[] metadataURIs;
    }

    // keccak256(abi.encode(uint256(keccak256("textDAO.textSavePassOp.texts")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant TEXTS_STORAGE_LOCATION =
        0x6b4e5911a84ec39982af20b4b46881b8065fae500bf9de0e93910e5b75a3be00;

    function $Texts() internal pure returns (TextSavePassOpStorage storage $) {
        assembly { $.slot := TEXTS_STORAGE_LOCATION }
    }

}
