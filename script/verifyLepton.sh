contract=$(jq -r '.transactions[0].contractAddress' broadcast/Lepton.s.sol/$chain/dry-run/run-latest.json)
forge verify-contract $contract Lepton --chain $chain --verifier etherscan --show-standard-json-input > io/$chain/Lepton.json
