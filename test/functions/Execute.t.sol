// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest} from "@devkit/Flattened.sol";

import {Execute} from "bundle/textDAO/functions/Execute.sol";
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";

contract ExecuteTest is MCTest {

    function setUp() public {
        _use(Execute.execute.selector, address(new Execute()));
    }

    function test_execute_success(uint256 executionBlockTime) public {
        uint pid = 0;
        Schema.Proposal storage $p = Storage.$Proposals().proposals[pid];
        $p.cmds.push();
        $p.proposalMeta.cmdRank = new uint[](3);

        vm.assume(executionBlockTime >= Storage.$Proposals().config.expiryDuration + $p.proposalMeta.createdAt);
        vm.warp(executionBlockTime);

        Execute(address(this)).execute(pid);
    }

    function test_execute_revert_beforeExpiration(uint256 expiryDuration, uint256 executionBlockTime) public {
        Storage.$Proposals().config.expiryDuration = expiryDuration;

        vm.assume(executionBlockTime < expiryDuration);
        vm.warp(executionBlockTime);

        vm.expectRevert("Proposal must be finished.");
        Execute(address(this)).execute(0);
    }

}
