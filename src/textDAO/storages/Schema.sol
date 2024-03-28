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
    struct ProposalArg {
        Header header;
        Command cmd;
        ProposalMeta proposalMeta;
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
    struct ProposalVars {
        uint[] headerRank;
        uint[] cmdRank;
        bool[] cmdConds;
        bool cmdCondSum;
        Header[3] topHeaders;
        Command[3] topCommands;
        uint headerRank2;
        uint cmdRank2;
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
    }
    struct ConfigOverride {
        uint quorumScore;
    }    

}
