deployer=0x4e59b44847b379578588920cA78FbF26c0B4956C
salt=0x0000000000000000000000000000000000000000000000000000000000000000
initcode=$(forge inspect Lepton bytecode)
initcodehash=$(cast keccak $initcode)
echo "initcodehash=$initcodehash"
input=$(cast concat-hex $salt $initcode)
printf '%s' "$input" > script/Lepton.txt
Lepton=$(cast create2 --deployer $deployer --salt $salt --init-code $initcode)
echo "Lepton=$Lepton"
forge verify-contract $Lepton Lepton --verifier etherscan --show-standard-json-input | jq '.'> script/Lepton.json
