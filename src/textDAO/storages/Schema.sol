// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title TextDAO Schema v0.1.0
 */
library Schema {
    /// @custom:storage-location erc7201:textDAO.ProposeStorage
    struct ProposeStorage {
        mapping(uint => Proposal) proposals;
        uint nextProposalId;
        ProposalsConfig config;
    }
    struct ProposalsConfig {
        uint expiryDuration;
        uint tallyInterval;
        uint repsNum;
        uint quorumScore;
    }
    struct ProposalNoTallied {
        Schema.Header[] headers;
        Schema.Command[] cmds;
        Schema.ProposalMeta proposalMeta;
    }
    struct Proposal {
        Header[] headers;
        Command[] cmds;
        mapping(uint => bool) tallied;
        ProposalMeta proposalMeta;
    }
    struct Header {
        uint id;
        uint currentScore;
        bytes32 metadataURI;
        uint[] tagIds;
    }
    struct Command {
        uint id;
        Action[] actions;
        uint currentScore;
    }
    struct Action {
        string func;
        bytes abiParams;
    }
    struct ProposalMeta {
        uint currentScore;
        uint[] headerRank;
        uint[] cmdRank;
        uint nextHeaderTallyFrom;
        uint nextCmdTallyFrom;
        address[] reps;
        uint nextRepId;
        uint createdAt;
    }

    /// @custom:storage-location erc7201:textDAO.TextSaveProtectedStorage
    struct TextSaveProtectedStorage {
        mapping(uint => Text) texts;
        uint nextTextId;
    }
    struct Text {
        uint id;
        bytes32[] metadataURIs;
    }

    /// @custom:storage-location erc7201:textDAO.MemberJoinProtectedStorage
    struct MemberJoinProtectedStorage {
        mapping(uint => Member) members;
        uint nextMemberId;
    }
    struct Member {
        uint id;
        address addr;
        bytes32 metadataURI;
    }

    /// @custom:storage-location erc7201:textDAO.VRFStorage
    struct VRFStorage {
        mapping(uint => Request) requests;
        uint nextId;
        uint64 subscriptionId;
        VRFConfig config;
    }
    struct Request {
        uint requestId;
        uint proposalId;
    }
    struct VRFConfig {
        address vrfCoordinator;
        bytes32 keyHash;
        uint32 callbackGasLimit;
        uint16 requestConfirmations;
        uint32 numWords;
        address LINKTOKEN;
    }

    /// @custom:storage-location erc7201:textDAO.ConfigOverrideStorage
    struct ConfigOverrideStorage {
        mapping(bytes4 => ConfigOverride) overrides;
        // bytes4[] overridesIndex;
    }
    struct ConfigOverride {
        uint quorumScore;
    }

    /// @custom:storage-location erc7201:textDAO.TagStorage
    struct TagStorage {
        mapping(uint => Tag) tags;
        uint nextId;
    }
    struct Tag {
        uint id;
        bytes32 metadataURI;
    }

    /// @custom:storage-location erc7201:textDAO.TagRelationStorage
    struct TagRelationStorage {
        mapping(uint => TagRelation) relations;
        uint nextId;
    }
    struct TagRelation {
        uint id;
        uint tagId;
        uint taggedId;
    }
}


