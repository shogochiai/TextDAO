// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library SelectorLib {    

    function selector(string memory func) internal pure returns (bytes4) {
        return bytes4(keccak256(bytes(func)));
    }

}
