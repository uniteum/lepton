// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Clones} from "clones/Clones.sol";
import {Script, console} from "forge-std/Script.sol";

/**
 * @notice Salt-mine {ICoinage.make} to find an input salt whose predicted clone
 *         address is strictly greater than a target address threshold.
 * @dev Inputs are read from environment variables:
 *      - LEPTON:      address of the deployed Lepton prototype (the factory)
 *      - MAKER:       address that will call {make} (the msg.sender at mint time)
 *      - NAME:        token name passed to {make}
 *      - SYMBOL:      token symbol passed to {make}
 *      - SUPPLY:      token supply passed to {make}
 *      - MIN_ADDRESS: address threshold — the mined clone address must be > this
 *      - START_SALT:  (optional) uint256 salt counter start, default 0
 *      - MAX_TRIES:   (optional) max iterations, default 10_000_000
 *
 *      Usage: forge script script/Mine.s.sol
 */
contract Mine is Script {
    function run() external {
        address lepton = vm.envAddress("ICoinage");
        address maker = vm.envAddress("maker");
        string memory name = vm.envString("name");
        string memory symbol = vm.envString("symbol");
        uint256 supply = vm.envUint("supply");
        address minAddress = vm.envAddress("minAddress");
        uint256 start = vm.envOr("startSalt", uint256(0));
        uint256 maxTries = vm.envOr("maxTries", uint256(10_000_000));

        console.log("Lepton:    ", lepton);
        console.log("Maker:     ", maker);
        console.log("Name:      ", name);
        console.log("Symbol:    ", symbol);
        console.log("Supply:    ", supply);
        console.log("MinAddress:", minAddress);
        console.log("Start:     ", start);
        console.log("MaxTries:  ", maxTries);

        uint160 threshold = uint160(minAddress);

        vm.pauseGasMetering();
        uint256 fmp;
        assembly ("memory-safe") {
            fmp := mload(0x40)
        }
        for (uint256 i = 0; i < maxTries; i++) {
            assembly ("memory-safe") {
                mstore(0x40, fmp)
            }
            bytes32 salt = bytes32(start + i);
            bytes32 create2Salt = keccak256(abi.encode(maker, name, symbol, supply, salt));
            address home = Clones.predictDeterministicAddress(lepton, create2Salt, lepton);
            if (uint160(home) > threshold) {
                console.log("Found after iterations:", i + 1);
                console.log("Salt (hex):");
                console.logBytes32(salt);
                console.log("Predicted address:", home);
                return;
            }
        }

        revert("Mine: no salt found within MAX_TRIES");
    }
}
