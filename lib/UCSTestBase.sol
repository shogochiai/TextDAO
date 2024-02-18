// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Test } from "forge-std/Test.sol";
import { DecodeErrorString } from "./DecodeErrorString.sol";
// import { console2 } from "forge-std/console2.sol";

abstract contract UCSTestBase is Test {
    mapping(bytes4 => address) implementations; // selector => impl

    function setUp() public virtual;

    fallback(bytes calldata) external payable returns (bytes memory){
        address opAddress = implementations[msg.sig];
        require(opAddress != address(0), "Called implementation is not registered.");
        (bool success, bytes memory data) = opAddress.delegatecall(msg.data);
        if (success) {
            return data;
        } else {
            // vm.expectRevert needs this.
            revert(DecodeErrorString.decodeRevertReasonAndPanicCode(data));
        }
    }
}