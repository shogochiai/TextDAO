// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { StorageLib } from "./StorageLib.sol";

contract VoteOp {
    function vote(uint pid, bool isYay) external returns (bool) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        if (isYay) {
          $.proposals[pid].yay++;
        } else {
          $.proposals[pid].nay++;
        }
    }
}
