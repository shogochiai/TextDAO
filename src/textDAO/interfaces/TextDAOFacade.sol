// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { Types } from "bundle/textDAO/storages/Types.sol";

contract TextDAOFacade {
    function clone(address _target) public {}
    function initialize(address[] calldata initialMembers, Schema.ProposalsConfig calldata pConfig) public {}
    function propose(Types.ProposalArg calldata _p) public returns (uint) {}
    function fork(uint _proposalId) public {}
    function voteHeaders(uint _proposalId, uint[3] calldata _headerIds) public {}
    function voteCmds(uint _proposalId, uint[3] calldata _cmdIds) public {}
    function tally(uint _proposalId) public {}
    function execute(uint _proposalId) public {}
    function memberJoin(uint _proposalId, Schema.Member[] calldata _candidates) public {}
    function setProposalsConfig(Schema.ProposalsConfig calldata _config) public {}
    function overrideProposalsConfig(uint _proposalId, Schema.ProposalsConfig calldata _config) public {}
    function saveText(uint _proposalId, string calldata _text) public {}
    function getProposal(uint id) external view returns (Schema.ProposalNoTallied memory) {}
    function getNextProposalId() external view returns (uint) {}
    function getProposalsConfig() external view returns (Schema.ProposalsConfig memory) {}
    function getText(uint id) external view returns (Schema.Text memory) {}
    function getNextTextId() external view returns (uint) {}
    function getMember(uint id) external view returns (Schema.Member memory) {}
    function getNextMemberId() external view returns (uint) {}
    function getVRFRequest(uint id) external view returns (Schema.Request memory) {}
    function getNextVRFId() external view returns (uint) {}
    function getSubscriptionId() external view returns (uint64) {}
    function getVRFConfig() external view returns (Schema.VRFConfig memory) {}
    function getConfigOverride(bytes4 sig) external view returns (Schema.ConfigOverride memory) {}
}
