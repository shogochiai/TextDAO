// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";
import { UCSTestBase } from "lib/UCSTestBase.sol";
import { DoubleOp } from "src/DoubleOp.sol";
import { ProposeOp } from "src/ProposeOp.sol";
import { VoteOp } from "src/VoteOp.sol";
import { StorageLib } from "src/StorageLib.sol";

contract UCSTestWithStateFuzzing is UCSTestBase {

    function setUp() public override {
        implementations[DoubleOp.double.selector] = address(new DoubleOp());
        implementations[ProposeOp.propose.selector] = address(new ProposeOp());
        implementations[VoteOp.vote.selector] = address(new VoteOp());
    }

    function test_double(uint x) public {
        bytes32 dummySlot1 = bytes32(uint(1));
        vm.assume(x < type(uint).max / 2);
        vm.store(address(this), dummySlot1/* ERC-7201 slot */, bytes32(x)/* for boundary condition check */);
        DoubleOp(address(this)).double(x);
        uint x2 = uint(vm.load(address(this), dummySlot1));
        assertEq(x * 2, x2);
    }

    function test_propose() public {
        StorageLib.Proposal memory p;
        uint pid = ProposeOp(address(this)).propose(p);
        assertEq(pid, 1);
        assertEq(StorageLib.$Proposals().proposals[pid].title, p.title);
    }

    function test_yayVote() public {
        uint pid = 1;
        uint yayBefore = StorageLib.$Proposals().proposals[pid].yay;
        VoteOp(address(this)).vote(pid, true);
        uint yayAfter = StorageLib.$Proposals().proposals[pid].yay;
        assertEq(yayBefore + 1, yayAfter);
    }


}
