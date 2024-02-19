#!/usr/bin/env sh

# keccak256(abi.encode(uint256(keccak256("example.main")) - 1)) & ~bytes32(uint256(0xff));
# 1. hash = keccak256("example.main")
# 2. hash_minus_one = hash - 1 = uint256(keccak256("example.main")) - 1)
# 3. second_hash = keccak256(hash_minus_one) = keccak256(abi.encode(uint256(keccak256("example.main")) - 1))
# 4. named_hash = keccak256(abi.encode(uint256(keccak256("example.main")) - 1)) & ~bytes32(uint256(0xff));
# named-hash("example.main")
#   -> 0x183a6125c38840424c4a85fa12bab2ab606c4b6d0e7cc73c0c06ba5300eab500

## 1. Calculate hash of name
hash=$(cast k $1)
# echo "hash: $hash"

## 2. Minus one
### 2-1. Since direct handling of 256-bit calculations is not possible on the shell, only the last 16 digits (64 bits, maximum capacity for calculating in the shell env) will be extracted for computation.
last_16_of_hash=${hash: -16}
# echo "last 16-digits of hash:                                 $last_16_of_hash"
last_16_of_hash_decimal=$((16#$last_16_of_hash))
# Check if the last 16 digits of hash decimal is 0
if [ "$last_16_of_hash_decimal" -eq 0 ]; then
    echo "Error: CANNOT calculate the storage location, because the decimal value of the last 16 digits of the hash is 0. Aborting..."
    exit 1
fi
# echo "last 16-digits of hash decimal:         $last_16_of_hash_decimal"
last_16_of_hash_minus_one_decimal=$((last_16_of_hash_decimal - 1))
# echo "last 16-digits of hash minus 1 decimal: $last_16_of_hash_minus_one_decimal"
last_16_of_hash_minus_one_hex=$(printf "%016x\n" $last_16_of_hash_minus_one_decimal)
# echo "last 16-digits of hash minus 1 hex:     $last_16_of_hash_minus_one_hex"
### 2-2. Concat
rest_of_hash="${hash%????????????????}" # 16-digits
# echo "$rest_of_hash"
second_hash_seed="${rest_of_hash}${last_16_of_hash_minus_one_hex}"
# echo "$second_hash_seed"

## 3. Calculate 2nd-hash
second_hash=$(cast k $second_hash_seed)
# echo "$second_hash"

## 4. Calculate final named_hash
rest_of_second_hash="${second_hash%??}"
named_hash="${rest_of_second_hash}00"
echo "$named_hash"