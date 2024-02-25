// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.23;

// import { UCSScriptBase } from "@ucs-ops/utils/UCSScriptBase.sol";
// import { ICloneOp } from "@ucs-ops/src/interfaces/ops/ICloneOp.sol";

// import { Propose } from "~/textDAO/functions/Propose.sol";
// import { Fork } from "~/textDAO/functions/Fork.sol";
// import { Vote } from "~/textDAO/functions/Vote.sol";
// import { Tally } from "~/textDAO/functions/Tally.sol";
// import { Execute } from "~/textDAO/functions/Execute.sol";
// import { MemberJoinProtected } from "~/textDAO/functions/protected/MemberJoinProtected.sol";
// import { SetConfigsProtected } from "~/textDAO/functions/protected/SetConfigsProtected.sol";
// import { ConfigOverrideProtected } from "~/textDAO/functions/protected/ConfigOverrideProtected.sol";
// import { SaveTextProtected } from "~/textDAO/functions/protected/SaveTextProtected.sol";

// contract Deployment is UCSScriptBase {
//     function run() public startBroadcastWithDeployerPrivKey {
//         address proxy = newProxy();
//         address dictionary = getDictionary(proxy);
//         opNames.push(OpName.Clone);
//         setOps(dictionary, opNames);
//         ICloneOp(proxy).clone("");
//     }
// }