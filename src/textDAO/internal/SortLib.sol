// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "./StorageLib.sol";

/**
 * SortLib v0.1.0
 */
library SortLib {    

    function rankHeaders(StorageLib.Header[] memory _headers) internal pure returns (uint[] memory) {
        uint length = _headers.length;
        uint[] memory indices = new uint[](length);
        
        // Initialize the indices array
        for (uint i = 0; i < length; i++) {
            indices[i] = i;
        }

        // Perform a simple bubble sort on the indices array, based on comparing the currentScore in bodyForks
        for (uint i = 0; i < length; i++) {
            for (uint j = 0; j < length - i - 1; j++) {
                if (_headers[indices[j]].currentScore < _headers[indices[j + 1]].currentScore) {
                    // Swap indices
                    (indices[j], indices[j + 1]) = (indices[j + 1], indices[j]);
                }
            }
        }

        // Return the array of original indices, now in sorted order
        return indices;
    }
    function rankCmds(StorageLib.Command[] memory _cmds) internal pure returns (uint[] memory) {
        uint length = _cmds.length;
        uint[] memory indices = new uint[](length);
        
        // Initialize the indices array
        for (uint i = 0; i < length; i++) {
            indices[i] = i;
        }

        // Perform a simple bubble sort on the indices array, based on comparing the currentScore in bodyForks
        for (uint i = 0; i < length; i++) {
            for (uint j = 0; j < length - i - 1; j++) {
                if (_cmds[indices[j]].currentScore < _cmds[indices[j + 1]].currentScore) {
                    // Swap indices
                    (indices[j], indices[j + 1]) = (indices[j + 1], indices[j]);
                }
            }
        }

        // Return the array of original indices, now in sorted order
        return indices;
    }

}
