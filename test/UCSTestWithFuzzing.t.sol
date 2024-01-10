// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

contract UCSTestWithStateFuzzing is Test {
    Op op;
    bytes32 dummySlot = bytes32(uint(1));

    function setUp() public {
        op = new Op();
    }

    function test_double(uint x) public {
        vm.assume(x < type(uint).max / 2);
        vm.store(address(this), dummySlot/* ERC-7201 slot */, bytes32(x)/* for boundary condition check */);
        address(this).call(abi.encodeWithSelector(op.double.selector, x));
        uint x2 = uint(vm.load(address(this), dummySlot));
        assertEq(x * 2, x2);
    }

    fallback() external payable {
        address opAddress = address(op);
        (bool success, ) = opAddress.delegatecall(msg.data);
        require(success);
    }
}

contract Op {
    function double(uint x) external {
        x *= 2;
        assembly {
            sstore(1, x)
        }
    }
}