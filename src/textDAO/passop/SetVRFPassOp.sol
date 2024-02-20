// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "../internal/StorageLib.sol";
import { PassOpBase } from "./PassOpBase.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract SetVRFPassOp is PassOpBase {
    function createAndFundSubscription(uint pid, uint96 amount) public onlyPassed(pid) returns (bool)  {
        StorageLib.VRFStorage storage $vrf = StorageLib.$VRF();

        // Create a new subscription
        $vrf.subscriptionId = VRFCoordinatorV2Interface($vrf.vrfCoordinator).createSubscription();

        // Fund the subscription with LINK tokens
        // Ensure this contract has enough LINK tokens before calling this
        IERC677($vrf.LINKTOKEN).transferAndCall(
            $vrf.vrfCoordinator,
            amount,
            abi.encode($vrf.subscriptionId));
    }
}

interface IERC677 {
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);
}