// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Clones} from "clones/Clones.sol";

/**
 * @title Prototype
 * @notice Base contract for self-cloning minimal proxy implementations.
 * @dev
 * The contract deployed as the Prototype acts as:
 *   - the reference implementation with canonical storage, and
 *   - a factory that deterministically deploys minimal proxy clones of itself.
 *
 * Each clone:
 *   - delegates all logic to the Prototype,
 *   - uses its own storage,
 *   - preserves the caller’s msg.sender,
 *   - inherits the same immutable proto address.
 *
 * All clones are deployed with CREATE2 using salts derived from initialization
 * data, ensuring predictable, repeatable addresses.
 * @author Paul Reinholdtsen (reinholdtsen.eth)
 */
abstract contract Prototype {
    /**
     * @notice Address of the original prototype implementation.
     */
    address public immutable proto = address(this);

    /**
     * @notice Predicts the clone address for a given args hash and variant.
     * @param argshash Hash of the ABI-encoded initialization args.
     * @param variant Variant identifier mixed into the salt.
     * @return home The deterministic clone address.
     * @return salt The CREATE2 salt derived from `argshash` and `variant`.
     */
    function made(bytes32 argshash, uint256 variant) public view returns (address home, bytes32 salt) {
        salt = argshash ^ bytes32(variant);
        home = Clones.predictDeterministicAddress(proto, salt, proto);
    }

    /**
     * @notice Predicts the clone address for initialization data.
     * @dev Salt is derived from `keccak256(abi.encode(args))` xor `variant`.
     * @param args Initialization calldata for the clone.
     * @param variant Variant identifier mixed into the salt.
     * @return home Deterministic clone address.
     * @return salt The CREATE2 salt derived from args and variant.
     */
    function made(bytes calldata args, uint256 variant) public view returns (address home, bytes32 salt) {
        // forge-lint: disable-next-line(asm-keccak256)
        bytes32 argshash = keccak256(abi.encode(args));
        (home, salt) = made(argshash, variant);
    }

    /**
     * @notice Deploys a deterministic minimal proxy clone.
     * @dev
     * On the Prototype:
     *   - Computes salt from args.
     *   - Deploys clone if it does not already exist.
     *   - Calls __initialize(args) on the new clone.
     *
     * On a clone:
     *   - Forwards the request back to the Prototype.
     *
     * @param args Initialization data passed to the clone.
     * @param variant Variant identifier mixed into the salt.
     * @return home The deployed clone address.
     */
    function make(bytes calldata args, uint256 variant) external returns (address home) {
        if (address(this) == proto) {
            bytes32 salt;
            (home, salt) = made(args, variant);

            if (home.code.length == 0) {
                home = Clones.cloneDeterministic(proto, salt, 0);
                Prototype(home).zzInit(args, variant);
            }
        } else {
            home = Prototype(proto).make(args, variant);
        }
    }

    /**
     * @notice Initialize a newly deployed clone.
     * @dev Must be implemented by derived classes.
     *      Only callable by the Prototype.
     * @param args ABI-encoded initialization parameters.
     * @param variant A variant identifier for the initialization.
     */
    function zzInit(bytes memory args, uint256 variant) public virtual onlyProto {}

    /**
     * @notice Restricts calls to the Prototype implementation.
     */
    modifier onlyProto() {
        _onlyProto();
        _;
    }

    /**
     * @dev Reverts if msg.sender is not the Prototype implementation.
     */
    function _onlyProto() internal view {
        if (msg.sender != proto) revert Unauthorized();
    }

    /**
     * @notice Error raised when a caller lacks permission.
     */
    error Unauthorized();
}
