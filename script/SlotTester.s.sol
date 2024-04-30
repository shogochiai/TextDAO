// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import { MCScript } from "@devkit/MCScript.sol";
import { Dummy } from "src/textdao/storages/Dummy.sol";

contract SlotTester is MCScript {

    function run() public startBroadcastWithDeployerPrivKey {       
        address addr = address(new Dummy()); 
        Dummy(addr).save();
    }
}
