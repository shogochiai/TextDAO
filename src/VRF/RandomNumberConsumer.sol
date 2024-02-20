// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@chainlink/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract RandomNumberConsumer is VRFConsumerBaseV2 {

    // Note: We don't use it.
    constructor(address _waste) VRFConsumerBaseV2(_waste) {}

    // TODO: Hit by the last line of propose onlyMember
    function requestRandomWords() external {
        uint64 s_subscriptionId = uint64(0);
        address vrfCoordinator = address(0);
        bytes32 keyHash = bytes32(0);
        uint32 callbackGasLimit = 2000000;
        uint16 requestConfirmations = 6;
        uint32 numWords =  1;

        // Assumes the subscription is funded sufficiently.
        uint256 requestId = VRFCoordinatorV2Interface(vrfCoordinator).requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    // TODO: Reserve callback from outer world
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWordsReturned) internal override {
        uint256[] memory randomWords = randomWordsReturned;

        // TODO: ITextDAO(proxy).callbackGetReps(randomWords) onlyVRF
    }
}