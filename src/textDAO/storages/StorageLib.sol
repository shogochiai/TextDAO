// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@chainlink/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

/**
 * StorageLib v0.1.0
 */
library StorageLib {    
    /*********************
     *  ProposeStorage
     ********************/
    /// @custom:storage-location erc7201:textDAO.proposeop.proposals
    struct ProposeStorage {
        mapping(uint => Proposal) proposals;
        uint nextProposalId;
        ProposalsConfig config;
    }
    struct ProposalsConfig {
        uint expiryDuration;
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
        uint[] headerRank;
        uint[] cmdRank;
        uint nextHeaderTallyFrom;
        uint nextCmdTallyFrom;
        address[] reps;
        uint nextRepId;
        uint createdAt;
    }

    // keccak256(abi.encode(uint256(keccak256("textDAO.proposeop.proposals")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant PROPOSALS_STORAGE_LOCATION =
        0xd43a2afe07b94a8ce70d10f193569d2c070c983eb6cea4616d25510ca5dae200;

    function $Proposals() internal pure returns (ProposeStorage storage $) {
        assembly { $.slot := PROPOSALS_STORAGE_LOCATION }
    }



    /*********************
     *  TextSavePass Storage
     ********************/
    /// @custom:storage-location erc7201:textDAO.textSavePass.texts
    struct TextSavePassStorage {
        mapping(uint => Text) texts;
        uint nextTextId;
    }
    struct Text {
        uint id;
        bytes32[] metadataURIs;
    }

    // keccak256(abi.encode(uint256(keccak256("textDAO.textSavePass.texts")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant TEXTS_STORAGE_LOCATION =
        0x6b4e5911a84ec39982af20b4b46881b8065fae500bf9de0e93910e5b75a3be00;

    function $Texts() internal pure returns (TextSavePassStorage storage $) {
        assembly { $.slot := TEXTS_STORAGE_LOCATION }
    }


    /*********************
     *  MemberJoinPass Storage
     ********************/
    /// @custom:storage-location erc7201:textDAO.memberJoinPass.members
    struct MemberJoinPassStorage {
        mapping(uint => Member) members;
        uint nextMemberId;
    }
    struct Member {
        uint id;
        address addr;
        bytes32 metadataURI;
    }

    // keccak256(abi.encode(uint256(keccak256("textDAO.memberJoinPass.members")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant MEMBERSS_STORAGE_LOCATION =
        0x2440ca222525c850943cc10edec2af9e450af2275dab1d00440eb269aaf15900;

    function $Members() internal pure returns (MemberJoinPassStorage storage $) {
        assembly { $.slot := MEMBERSS_STORAGE_LOCATION }
    }


    /*********************
     *  VRF Storage
     ********************/
    /// @custom:storage-location erc7201:textDAO.vrf.vrf
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

    // keccak256(abi.encode(uint256(keccak256("textDAO.vrf.vrf")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant VRF_STORAGE_LOCATION =
        0xd9fa33bd289c873d1fdb39b1afdc38aa40e8cb7210f0fbe10770706df952a700;

    function $VRF() internal pure returns (VRFStorage storage $) {
        assembly { $.slot := VRF_STORAGE_LOCATION }
    }

    

}
