// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";

/**
 * SortLib v0.1.0
 */
library SortLib {

    function rankHeaders(Schema.Header[] memory _headers, uint nextHeaderTallyFrom) internal pure returns (uint[] memory) {
        uint headerLength = _headers.length;
        if(nextHeaderTallyFrom >= headerLength) return new uint[](0); // Return empty if out of bounds

        uint listLength = headerLength - nextHeaderTallyFrom;
        uint[] memory indices = new uint[](listLength);

        // Initialize the indices array for the part of the array we're interested in sorting
        for (uint i = 0; i < listLength; i++) {
            indices[i] = i + nextHeaderTallyFrom;
        }

        // Perform a simple bubble sort on the indices array, based on comparing the currentScore in _headers
        for (uint i = 0; i < listLength; i++) {
            for (uint j = 0; j < listLength - i - 1; j++) {
                if (_headers[indices[j]].currentScore < _headers[indices[j + 1]].currentScore) {
                    // Swap indices
                    (indices[j], indices[j + 1]) = (indices[j + 1], indices[j]);
                }
            }
        }

        // Return the array of original indices, now in sorted order, only considering elements after nextHeaderTallyFrom
        return indices;
    }

    function rankCmds(Schema.Command[] memory _cmds, uint nextCmdTallyFrom) internal pure returns (uint[] memory) {
        uint cmdsLength = _cmds.length;
        if(nextCmdTallyFrom >= cmdsLength) return new uint[](0); // Return empty if out of bounds

        uint listLength = cmdsLength - nextCmdTallyFrom;
        uint[] memory indices = new uint[](listLength);

        // Initialize the indices array for the part of the array we're interested in sorting
        for (uint i = 0; i < listLength; i++) {
            indices[i] = i + nextCmdTallyFrom;
        }

        // Perform a simple bubble sort on the indices array, based on comparing the currentScore in _cmds
        for (uint i = 0; i < listLength; i++) {
            for (uint j = 0; j < listLength - i - 1; j++) {
                if (_cmds[indices[j]].currentScore < _cmds[indices[j + 1]].currentScore) {
                    // Swap indices
                    (indices[j], indices[j + 1]) = (indices[j + 1], indices[j]);
                }
            }
        }

        // Return the array of original indices, now in sorted order, only considering elements after nextCmdTallyFrom
        return indices;
    }
}
