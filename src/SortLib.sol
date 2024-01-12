// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { StorageLib } from "./StorageLib.sol";

/**
 * SortLib v0.1.0
 */
library SortLib {    

    function rankHeaderForks(StorageLib.HeaderFork[] memory _hfs) internal pure returns (uint[] memory) {
        uint length = _hfs.length;
        uint[] memory indices = new uint[](length);
        
        // Initialize the indices array
        for (uint i = 0; i < length; i++) {
            indices[i] = i;
        }

        // Perform a simple bubble sort on the indices array, based on comparing the currentScore in bodyForks
        for (uint i = 0; i < length; i++) {
            for (uint j = 0; j < length - i - 1; j++) {
                if (_hfs[indices[j]].currentScore < _hfs[indices[j + 1]].currentScore) {
                    // Swap indices
                    (indices[j], indices[j + 1]) = (indices[j + 1], indices[j]);
                }
            }
        }

        // Return the array of original indices, now in sorted order
        return indices;
    }
    function rankBodyForks(StorageLib.BodyFork[] memory _bfs) internal pure returns (uint[] memory) {
        uint length = _bfs.length;
        uint[] memory indices = new uint[](length);
        
        // Initialize the indices array
        for (uint i = 0; i < length; i++) {
            indices[i] = i;
        }

        // Perform a simple bubble sort on the indices array, based on comparing the currentScore in bodyForks
        for (uint i = 0; i < length; i++) {
            for (uint j = 0; j < length - i - 1; j++) {
                if (_bfs[indices[j]].currentScore < _bfs[indices[j + 1]].currentScore) {
                    // Swap indices
                    (indices[j], indices[j + 1]) = (indices[j + 1], indices[j]);
                }
            }
        }

        // Return the array of original indices, now in sorted order
        return indices;
    }

}
