deployer=0x4e59b44847b379578588920cA78FbF26c0B4956C
salt=0x000000000000000000000000000000000000000000000000000000002b3fbfee
initcode=$(forge inspect Lepton bytecode)
initcodehash=$(cast keccak $initcode)
echo "initcodehash=$initcodehash"
Lepton=$(cast create2 --deployer $deployer --salt $salt --init-code $initcode)
echo "Lepton=$Lepton"
input=$(cast concat-hex $salt $initcode)
printf '%s' "$input" > io/Lepton/$Lepton.txt
forge verify-contract $Lepton Lepton --verifier etherscan --show-standard-json-input | jq '.'> io/Lepton/$Lepton.json
