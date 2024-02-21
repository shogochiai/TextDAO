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
    /// @custom:storage-location erc7201:textDAO.PROPOSALS_STORAGE_LOCATION
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

    // keccak256(abi.encode(uint256(keccak256("textDAO.PROPOSALS_STORAGE_LOCATION")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant PROPOSALS_STORAGE_LOCATION =
        0xf1a4d8eab6724b783b75a5c8d6b4a5edac1afaa52adaa7d3c57201451ce8c400;

    function $Proposals() internal pure returns (ProposeStorage storage $) {
        assembly { $.slot := PROPOSALS_STORAGE_LOCATION }
    }



    /*********************
     *  TextSaveUnsafe Storage
     ********************/
    /// @custom:storage-location erc7201:textDAO.TEXTS_STORAGE_LOCATION
    struct TextSaveUnsafeStorage {
        mapping(uint => Text) texts;
        uint nextTextId;
    }
    struct Text {
        uint id;
        bytes32[] metadataURIs;
    }

    // keccak256(abi.encode(uint256(keccak256("textDAO.TEXTS_STORAGE_LOCATION")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant TEXTS_STORAGE_LOCATION =
        0x0a45678f7ac13226a0ead4e3b54db0ab263e1a30cc1ea3f19d7212aea5cd1d00;

    function $Texts() internal pure returns (TextSaveUnsafeStorage storage $) {
        assembly { $.slot := TEXTS_STORAGE_LOCATION }
    }


    /*********************
     *  MemberJoinUnsafe Storage
     ********************/
    /// @custom:storage-location erc7201:textDAO.MEMBERS_STORAGE_LOCATION
    struct MemberJoinUnsafeStorage {
        mapping(uint => Member) members;
        uint nextMemberId;
    }
    struct Member {
        uint id;
        address addr;
        bytes32 metadataURI;
    }

    // keccak256(abi.encode(uint256(keccak256("textDAO.MEMBERS_STORAGE_LOCATION")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant MEMBERS_STORAGE_LOCATION =
        0x2f8cab7d49dc616a0e8eb4e6f8b67d31c656445bf0c9ad5e38bc38d1128dcc00;

    function $Members() internal pure returns (MemberJoinUnsafeStorage storage $) {
        assembly { $.slot := MEMBERS_STORAGE_LOCATION }
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

    // keccak256(abi.encode(uint256(keccak256("textDAO.VRF_STORAGE_LOCATION")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant VRF_STORAGE_LOCATION =
        0x67f28ff67f7d7020f2b2ac7c9bd5f2a6dd9f19a9b15d92c4070c4572728ab000;

    function $VRF() internal pure returns (VRFStorage storage $) {
        assembly { $.slot := VRF_STORAGE_LOCATION }
    }

    

}
