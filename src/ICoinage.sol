// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title ICoinage
 * @notice Interface for an ERC-20 token maker.
 * @author Paul Reinholdtsen (reinholdtsen.eth)
 */
interface ICoinage {
    /**
     * @notice Checks whether a token with the given parameters has already been deployed.
     * @param name   The token name.
     * @param symbol The token symbol.
     * @param supply The total supply.
     * @return yes  `true` if the clone already exists.
     * @return home The deterministic address of the clone.
     * @return salt The CREATE2 salt derived from `(name, symbol, supply)`.
     */
    function made(string calldata name, string calldata symbol, uint256 supply)
        external
        view
        returns (bool yes, address home, bytes32 salt);

    /**
     * @notice Deploys a new ERC-20 token (or returns the existing one) and
     *         mints the full supply to the caller.
     * @param name   The token name.
     * @param symbol The token symbol.
     * @param supply The total supply to mint.
     * @return token The address of the (possibly pre-existing) token.
     */
    function make(string calldata name, string calldata symbol, uint256 supply) external returns (ICoinage token);

    /**
     * @notice Emitted when a new ERC-20 token is created via {make}.
     * @param maker       The address that called {make}.
     * @param token       The newly created token.
     * @param name        The token name.
     * @param symbol      The token symbol.
     * @param totalSupply The supply minted to `maker`.
     */
    event Make(address indexed maker, ICoinage indexed token, string name, string symbol, uint256 totalSupply);

    /**
     * @notice Thrown when the token name is empty.
     */
    error Nameless();

    /**
     * @notice Thrown when the token symbol is empty.
     */
    error Symbolless();

    /**
     * @notice Thrown when the supply is zero.
     */
    error Nothing();

    /**
     * @notice Thrown when a function restricted to the maker is called by another address.
     */
    error Unauthorized();
}
