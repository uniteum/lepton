deployer=0x1EB8901612767C04b3819E8A743ADCe88F9Fe110
initcode="0x3d602d80600a3d3981f3363d3d373d3d3d363d73${deployer#0x}5af43d82803e903d91602b57fd5bf3"
initcodehash=$(cast keccak "$initcode")
echo "initcodehash=$initcodehash"

argshash=$(cast keccak "$(cast abi-encode "f(address,string,string,uint8,uint256)" \
  "$maker" "$name" "$symbol" "$decimals" "$supply")")

# XOR argshash ^ variant (bc has no XOR, so use python)
salt=$(python3 -c "print(f'0x{int(\"$argshash\",16) ^ int(\"$variant\",16):064x}')")
echo "salt=$salt"

home=$(cast create2 --deployer "$deployer" --salt "$salt" --init-code "$initcode")
echo "home=$home"

input=$(cast calldata "make(string,string,uint8,uint256,uint256)" "$name" "$symbol" "$decimals" "$supply" "$variant")
mkdir -p "io/$name"
printf '%s' "$input" > "io/$name/$home.txt"
