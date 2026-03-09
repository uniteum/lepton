// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console2} from "forge-std/Script.sol";
import {Lepton} from "../src/Lepton.sol";

/// @notice Deploy the Lepton contract.
/// @dev Usage: forge script script/Lepton.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10
contract LeptonProto is Script {
    function run() public {
        vm.startBroadcast();

        Lepton proto = new Lepton{salt: 0x0}();
        console2.log("Deployed Lepton proto at:", address(proto));

        vm.stopBroadcast();
    }
}
