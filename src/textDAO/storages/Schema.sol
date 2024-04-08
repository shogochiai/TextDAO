// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * Schema v0.1.0
 */
library Schema {    
    /*********************
     *  ProposeStorage
     ********************/
    /// @custom:storage-location erc7201:textDAO.PROPOSALS_STORAGE_LOCATION
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

    /*********************
     *  TextSaveProtected Storage
     ********************/
    /// @custom:storage-location erc7201:textDAO.TEXTS_STORAGE_LOCATION
    struct TextSaveProtectedStorage {
        mapping(uint => Text) texts;
        uint nextTextId;
    }
    struct Text {
        uint id;
        bytes32[] metadataURIs;
    }

    /*********************
     *  MemberJoinProtected Storage
     ********************/
    /// @custom:storage-location erc7201:textDAO.MEMBERS_STORAGE_LOCATION
    struct MemberJoinProtectedStorage {
        mapping(uint => Member) members;
        uint nextMemberId;
    }
    struct Member {
        uint id;
        address addr;
        bytes32 metadataURI;
    }


    /*********************
     *  VRF Storage
     ********************/
    /// @custom:storage-location erc7201:textDAO.VRF_STORAGE_LOCATION
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


    /*********************
     *  ConfigOverride Storage
     ********************/
    /// @custom:storage-location erc7201:textDAO.CONF_OVERRIDE_STORAGE_LOCATION
    struct ConfigOverrideStorage {
        mapping(bytes4 => ConfigOverride) overrides;
        // bytes4[] overridesIndex;
    }
    struct ConfigOverride {
        uint quorumScore;
    }    


    /*********************
     *  Tag Storage
     ********************/
    /// @custom:storage-location erc7201:textDAO.TAG_STORAGE_LOCATION
    struct TagStorage {
        mapping(uint => Tag) tags;
        uint nextId;
    }
    struct Tag {
        uint id;
        bytes32 metadataURI;
    }


    /*********************
     *  TagRelation Storage
     ********************/
    /// @custom:storage-location erc7201:textDAO.TAG_RELATION_STORAGE_LOCATION
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


