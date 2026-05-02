#!/usr/bin/env bash
set -euo pipefail

deployer=0x1EB8901612767C04b3819E8A743ADCe88F9Fe110
maker=0xff966FE50802B74B538D2c6311Fc0201014AA294
variant=0x00000000000000000000000000000000000000000000000000000000000b1868 
name=pi
symbol=π
decimals=18
supply=3141592653589793238
target=0x3141592653589793238462643383279502884197
mask=0xfff000000000000000000000000000000000ffff

initcode="0x3d602d80600a3d3981f3363d3d373d3d3d363d73${deployer#0x}5af43d82803e903d91602b57fd5bf3"
initcodehash=$(cast keccak "$initcode")

argshash=$(cast keccak "$(cast abi-encode "f(address,string,string,uint8,uint256)" \
  "$maker" "$name" "$symbol" "$decimals" "$supply")")

# XOR argshash ^ variant (bc has no XOR, so use python)
salt=$(python3 -c "print(f'0x{int(\"$argshash\",16) ^ int(\"$variant\",16):064x}')")

home=$(cast create2 --deployer "$deployer" --salt "$salt" --init-code "$initcode")
input=$(cast calldata "make(string,string,uint8,uint256,uint256)" \
  "$name" "$symbol" "$decimals" "$supply" "$variant")

echo "initcodehash=$initcodehash"
echo "salt=$salt"
echo "home=$home"
echo "input=$input"

mkdir -p io/pi
printf '%s' "$input" > "io/pi/$home.txt"
