// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ICoinage} from "ierc20/ICoinage.sol";
import {ERC20} from "erc20/ERC20.sol";
import {Clones} from "clones/Clones.sol";

/// @notice Minimalist fixed-supply ERC-20 maker. A single call to {make}
///         deploys a new ERC-20 clone and mints the entire supply to the caller.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
contract Lepton is ICoinage, ERC20 {
    /// @notice The prototype instance used as the EIP-1167 implementation.
    Lepton public immutable PROTOTYPE = this;

    constructor() ERC20("Lepton Factory", "PROTOTYPE") {}

    /// @inheritdoc ICoinage
    function made(string calldata name, string calldata symbol, uint256 supply)
        public
        view
        returns (bool deployed, address home, bytes32 salt)
    {
        if (bytes(name).length == 0) revert Nameless();
        if (bytes(symbol).length == 0) revert Symbolless();
        if (supply == 0) revert Nothing();
        salt = keccak256(abi.encode(name, symbol, supply));
        home = Clones.predictDeterministicAddress(address(PROTOTYPE), salt, address(PROTOTYPE));
        deployed = home.code.length > 0;
    }

    /// @inheritdoc ICoinage
    function make(string calldata name, string calldata symbol, uint256 supply) external returns (ICoinage token) {
        (bool deployed, address home, bytes32 salt) = made(name, symbol, supply);
        token = ICoinage(home);
        if (deployed) {
            // return the deployed contract address.
        } else {
            home = Clones.cloneDeterministic(address(PROTOTYPE), salt, 0);
            Lepton(home).zzz_(msg.sender, name, symbol, supply);
        }
    }

    /// @notice Initialiser called by the prototype on a freshly deployed clone.
    /// @dev Reverts with {Unauthorized} otherwise.
    function zzz_(address maker, string calldata name, string calldata symbol, uint256 supply) public {
        if (msg.sender != address(PROTOTYPE)) {
            revert Unauthorized();
        }
        _name = name;
        _symbol = symbol;
        _mint(maker, supply);
        emit Make(maker, ICoinage(address(this)), name, symbol, supply);
    }
}
