// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Lepton} from "../src/Lepton.sol";
import {ProtoScript} from "crucible/script/Proto.s.sol";

/// @notice Deploy the Lepton contract.
/// @dev Usage: forge script script/Lepton.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10
contract LeptonProto is ProtoScript {
    function name() internal pure override returns (string memory) {
        return "LeptonProto";
    }

    function creationCode() internal pure override returns (bytes memory) {
        return type(Lepton).creationCode;
    }
}
