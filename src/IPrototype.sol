// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title IPrototype
 * @notice Interface for self-cloning minimal proxy implementations.
 * @dev
 * A Prototype acts as both:
 *   - the reference implementation with canonical storage, and
 *   - a factory that deterministically deploys minimal proxy clones of itself.
 *
 * Each clone:
 *   - delegates all logic to the Prototype,
 *   - uses its own storage,
 *   - preserves the caller's msg.sender,
 *   - inherits the same immutable proto address.
 *
 * All clones are deployed with CREATE2 using salts derived from initialization
 * data, ensuring predictable, repeatable addresses.
 * @author Paul Reinholdtsen (reinholdtsen.eth)
 */
interface IPrototype {
    /**
     * @notice Address of the original prototype implementation.
     */
    function proto() external view returns (address);

    /**
     * @notice Predicts the clone address for a given args hash and variant.
     * @param argshash Hash of the ABI-encoded initialization args.
     * @param variant Variant identifier mixed into the salt.
     * @return home The deterministic clone address.
     * @return salt The CREATE2 salt derived from `argshash` and `variant`.
     */
    function made(bytes32 argshash, uint256 variant) external view returns (address home, bytes32 salt);

    /**
     * @notice Predicts the clone address for initialization data.
     * @dev Salt is derived from `keccak256(abi.encode(args))` xor `variant`.
     * @param args Initialization calldata for the clone.
     * @param variant Variant identifier mixed into the salt.
     * @return home Deterministic clone address.
     * @return salt The CREATE2 salt derived from args and variant.
     */
    function made(bytes calldata args, uint256 variant) external view returns (address home, bytes32 salt);

    /**
     * @notice Deploys a deterministic minimal proxy clone.
     * @param args Initialization data passed to the clone.
     * @param variant Variant identifier mixed into the salt.
     * @return home The deployed clone address.
     */
    function make(bytes calldata args, uint256 variant) external returns (address home);

    /**
     * @notice Initialize a newly deployed clone.
     * @dev Only callable by the Prototype.
     * @param args ABI-encoded initialization parameters.
     * @param variant A variant identifier for the initialization.
     */
    function zzInit(bytes calldata args, uint256 variant) external;

    /**
     * @notice Error raised when a caller lacks permission.
     */
    error Unauthorized();
}
