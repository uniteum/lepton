// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

/**
 * @title ILepton
 * @notice Interface for the Lepton fixed-supply ERC-20 maker.
 * @author Paul Reinholdtsen (reinholdtsen.eth)
 */
interface ILepton {
    /**
     * @notice Emitted when a new ERC-20 token is created via {make}.
     * @param maker       The address that called {make}.
     * @param lepton      The newly created token clone.
     * @param name        The token name.
     * @param symbol      The token symbol.
     * @param totalSupply The entire supply minted to `maker`.
     */
    event Make(address indexed maker, ILepton indexed lepton, string name, string symbol, uint256 totalSupply);

    /** @notice Thrown when any of the token parameters are empty/zero. */
    error Nothing();

    /** @notice Thrown when a function restricted to the prototype is called by another address. */
    error Unauthorized();

    /**
     * @notice Checks whether a token with the given parameters has already been deployed.
     * @param n The token name.
     * @param s The token symbol.
     * @param t The total supply.
     * @return yes  `true` if the clone already exists.
     * @return home The deterministic address of the clone.
     * @return salt The CREATE2 salt derived from `(n, s, t)`.
     */
    function made(string calldata n, string calldata s, uint256 t)
        external
        view
        returns (bool yes, address home, bytes32 salt);

    /**
     * @notice Deploys a new ERC-20 clone (or returns the existing one) and
     *         mints the entire supply to the caller.
     * @dev Uses EIP-1167 minimal proxies with a deterministic salt so that
     *      each unique `(name, symbol, totalSupply)` tuple maps to exactly one
     *      clone address. Reverts via {Nothing} if any parameter is empty/zero.
     * @param n The token name.
     * @param s The token symbol.
     * @param t The total supply to mint.
     * @return lepton The address of the (possibly pre-existing) clone.
     */
    function make(string calldata n, string calldata s, uint256 t) external returns (ILepton lepton);
}
