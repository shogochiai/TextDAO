// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, stdStorage, StdStorage } from "forge-std/Test.sol";
import { UCSTestBase } from "lib/UCSTestBase.sol";
import { DoubleOp } from "src/DoubleOp.sol";
import { ProposeOp } from "src/ProposeOp.sol";

contract UCSTestWithStateFuzzing is UCSTestBase {
    using stdStorage for StdStorage;
    bytes32 dummySlot1 = bytes32(uint(1));
    bytes32 dummySlot2 = bytes32(uint(2));

    function setUp() public override {
        implementations[DoubleOp.double.selector] = address(new DoubleOp());
        implementations[ProposeOp.propose.selector] = address(new ProposeOp());
    }

    function test_double(uint x) public {
        vm.assume(x < type(uint).max / 2);
        vm.store(address(this), dummySlot1/* ERC-7201 slot */, bytes32(x)/* for boundary condition check */);
        DoubleOp(address(this)).double(x);
        uint x2 = uint(vm.load(address(this), dummySlot1));
        assertEq(x * 2, x2);
    }

    function test_propose() public {
        uint pid = ProposeOp(address(this)).propose("This is a testProposal.");
        assertGt(pid, 0);
    }

}
