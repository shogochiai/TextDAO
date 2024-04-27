// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Schema } from "bundle/textdao/storages/Schema.sol";

contract Dummy {
    Schema.ProposeStorage $;
    uint256 private constant baseSlot = 0xf1a4d8eab6724b783b75a5c8d6b4a5edac1afaa52adaa7d3c57201451ce8c400;
    
    function get() internal pure returns (Schema.ProposeStorage storage _$) {
        assembly {
            _$.slot := baseSlot
        }
    }

    function save() public returns (bool) {
        $.nextProposalId = 1;
        get().nextProposalId = 1;
        $.proposals[0].tallied[0] = true;
        get().proposals[0].tallied[0] = true;
        return true;
    }

    function dump1() public view returns (uint) {
        return $.nextProposalId;
    }
    function dump2() public view returns (uint) {
        return get().nextProposalId;
    }

}
