// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {ERC20} from "erc20/ERC20.sol";
import {Clones} from "clones/Clones.sol";
import {ILepton} from "./ILepton.sol";

/**
 * @title Lepton
 * @notice Minimalist fixed-supply ERC-20 maker. A single call to {make}
 *         deploys a new ERC-20 clone and mints the entire supply to the caller.
 * @dev Simple, UI-free token maker suitable for direct use from Etherscan.
 * @author Paul Reinholdtsen (reinholdtsen.eth)
 */
contract Lepton is ILepton, ERC20 {
    /// @notice The prototype instance used as the EIP-1167 implementation.
    Lepton public immutable PROTOTYPE = this;

    constructor() ERC20("Lepton Factory", "PROTOTYPE") {}

    /// @inheritdoc ILepton
    function made(string calldata n, string calldata s, uint256 t)
        public
        view
        returns (bool yes, address home, bytes32 salt)
    {
        if (bytes(n).length == 0 || bytes(s).length == 0 || t == 0) {
            revert Nothing();
        }
        salt = keccak256(abi.encode(n, s, t));
        home = Clones.predictDeterministicAddress(address(PROTOTYPE), salt, address(PROTOTYPE));
        yes = home.code.length > 0;
    }

    /// @inheritdoc ILepton
    function make(string calldata n, string calldata s, uint256 t) external returns (ILepton lepton) {
        (bool yes, address home, bytes32 salt) = made(n, s, t);
        lepton = ILepton(home);
        if (!yes) {
            home = Clones.cloneDeterministic(address(PROTOTYPE), salt, 0);
            Lepton(home).zzz_(msg.sender, n, s, t);
        }
    }

    /**
     * @notice Initialiser called by the prototype on a freshly deployed clone.
     * @dev MUST only be callable by the prototype contract; reverts with
     *      {Unauthorized} otherwise.
     * @param maker The address that triggered {make}.
     * @param n     The token name.
     * @param s     The token symbol.
     * @param t     The total supply to mint to `maker`.
     */
    function zzz_(address maker, string calldata n, string calldata s, uint256 t) public {
        if (msg.sender != address(PROTOTYPE)) {
            revert Unauthorized();
        }
        _name = n;
        _symbol = s;
        _mint(maker, t);
        emit Make(maker, ILepton(address(this)), n, s, t);
    }
}
