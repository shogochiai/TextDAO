pragma solidity 0.8.23;


library DecodeErrorString {
    /**
     * @dev Decodes a revert reason from ABI-encoded data.
     * @param data ABI-encoded revert reason.
     * @return reason The decoded revert reason as a string.
     */
    function decodeRevertReason(bytes memory data) internal pure returns (string memory reason) {
        // Require that the data length is at least enough to contain a length prefix
        require(data.length >= 4, "Data too short");
        // Skip the function selector
        assembly {
            reason := add(data, 0x04)
        }
    }

    /**
     * @dev Decodes a panic code from bytes.
     * @param data Bytes containing the panic code.
     * @return code The decoded panic code as a uint256.
     */
    function decodePanicCode(bytes memory data) internal pure returns (uint256 code) {
        require(data.length >= 4, "Data too short for panic code");
        // Panic codes are 4 bytes long, following the function selector
        assembly {
            code := mload(add(data, 0x24))
        }
    }

    /**
     * @dev Attempts to decode both revert reasons and panic codes.
     * @param data Bytes containing either a revert reason or a panic code.
     * @return result The decoded message as a string.
     */
    function decodeRevertReasonAndPanicCode(bytes memory data) internal pure returns (string memory result) {
        // Check if the data length corresponds to a panic code (4 bytes for the selector + 32 bytes for the uint256)
        if (data.length == 36) {
            uint256 panicCode = decodePanicCode(data);
            result = string(abi.encodePacked("Panic code: ", panicCode));
        } else {
            // Assume it's a revert reason for any other length
            result = decodeRevertReason(data);
        }
    }
}