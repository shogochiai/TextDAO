
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { ProtectionBase } from "bundle/_utils/ProtectionBase.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract SetConfigsProtected is ProtectionBase {
    function setProposalsConfig(uint pid, Schema.ProposalsConfig memory config) public protected(pid) returns (bool) {
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        $.config.expiryDuration = config.expiryDuration;
        $.config.repsNum = config.repsNum;
        $.config.quorumScore = config.quorumScore;
    }

    function setVRFConfig(uint pid, Schema.VRFConfig memory config) public protected(pid) returns (bool) {
        Schema.VRFStorage storage $vrf = Storage.$VRF();
        $vrf.config.vrfCoordinator = config.vrfCoordinator;
        $vrf.config.keyHash = config.keyHash;
        $vrf.config.callbackGasLimit = config.callbackGasLimit;
        $vrf.config.requestConfirmations = config.requestConfirmations;
        $vrf.config.numWords = config.numWords;
        $vrf.config.LINKTOKEN = config.LINKTOKEN;
    }

    function createAndFundVRFSubscription(uint pid, uint96 amount) public protected(pid) returns (bool) {
        Schema.VRFStorage storage $vrf = Storage.$VRF();

        // Create a new subscription
        $vrf.subscriptionId = VRFCoordinatorV2Interface($vrf.config.vrfCoordinator).createSubscription();

        // Fund the subscription with LINK tokens
        // Ensure this contract has enough LINK tokens before calling this
        IERC677($vrf.config.LINKTOKEN).transferAndCall(
            $vrf.config.vrfCoordinator,
            amount,
            abi.encode($vrf.subscriptionId));
    }

}

interface IERC677 {
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);
}
