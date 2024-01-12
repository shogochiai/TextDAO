// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { StorageLib } from "./StorageLib.sol";
import { console2 } from "forge-std/console2.sol";

contract ExecuteOp {
    function execute(uint pid) external returns (bool) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage p = $.proposals[pid];
        console2.logUint(p.yay);
        console2.logUint(p.quorum);
        if (p.yay >= p.quorum && p.yay > p.nay) {
          for (uint i; i < p.commands.length; i++) {
             StorageLib.Command memory cmd = p.commands[i];
             // Hopefully, check whitelist of registered ops
             (bool result,) = cmd.target.call(cmd.txbytes);
             require(result);
          }
          $.globalSuperImportantFlag = true;
        } else {
          revert("Execution denied: Quorum is not reached.");
        }
    }
}
