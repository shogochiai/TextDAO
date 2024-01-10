// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract DoubleOp {
    function double(uint x) external {
        x *= 2;
        assembly {
            sstore(1, x)
        }
    }
}