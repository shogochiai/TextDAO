pragma solidity 0.8.23;


library DecodeErrorString {
    function decodeRevertReason(bytes memory data) public pure returns (string memory) {
        // Ensure the data is at least 4 + 32 + 32 bytes (function selector + offset + string length)
        require(data.length >= 68, "Data too short");

        // Skip the first 4 bytes (error signature) and the next 32 bytes (offset),
        // then read the next 32 bytes to get the string length
        uint256 stringLength;
        assembly {
            stringLength := mload(add(data, 68))
        }

        // Extract the string itself
        bytes memory stringData = new bytes(stringLength);
        for (uint256 i = 0; i < stringLength; i++) {
            stringData[i] = data[i + 68];
        }

        return string(stringData);
    }
}