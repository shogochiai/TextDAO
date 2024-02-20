// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.23;

// import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
// import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

// contract RandomNumberConsumer is VRFConsumerBaseV2 {
//     VRFCoordinatorV2Interface COORDINATOR;
//     uint64 s_subscriptionId;
//     address vrfCoordinator = /* VRF Coordinator address */;
//     bytes32 keyHash = /* Key hash */;
//     uint32 callbackGasLimit = /* Callback gas limit */;
//     uint16 requestConfirmations = /* Request confirmations */;
//     uint32 numWords =  /* Number of words */;

//     // The requestId returned from requestRandomWords is used to match the request with the response.
//     // You could use this to match the randomness request with its response in your application.
//     uint256 public requestId;
//     uint256[] public randomWords;
//     uint256 public s_requestId;

//     constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
//         COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
//         s_subscriptionId = subscriptionId;
//     }

//     // TODO: Hit by the last line of propose onlyMember
//     function requestRandomWords() external {
//         // Assumes the subscription is funded sufficiently.
//         requestId = COORDINATOR.requestRandomWords(
//             keyHash,
//             s_subscriptionId,
//             requestConfirmations,
//             callbackGasLimit,
//             numWords
//         );
//     }

//     // TODO: Reserve callback from outer world
//     function fulfillRandomWords(uint256 requestId, uint256[] memory randomWordsReturned) internal override {
//         requestId = s_requestId; // Consider how best to use requestId in your contract's logic.
//         randomWords = randomWordsReturned;

//         // TODO: ITextDAO(proxy).callbackGetReps(randomWords) onlyVRF
//     }
// }