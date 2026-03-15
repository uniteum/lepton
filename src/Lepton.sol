// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ICoinage} from "ierc20/ICoinage.sol";
import {ERC20} from "erc20/ERC20.sol";
import {Clones} from "clones/Clones.sol";

/// @notice Minimalist fixed-supply ERC-20 maker.
///         Calling {make} deploys a new clone and mints the entire supply to the caller.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
contract Lepton is ICoinage, ERC20 {
    /// @notice The prototype instance used as the EIP-1167 implementation.
    address public immutable PROTOTYPE = address(this);

    constructor() ERC20("Lepton Factory", "PROTOTYPE") {}

    /// @inheritdoc ICoinage
    function made(address maker, string calldata name, string calldata symbol, uint256 supply)
        public
        view
        returns (bool deployed, address home, bytes32 salt)
    {
        if (bytes(name).length == 0) revert Nameless();
        if (bytes(symbol).length == 0) revert Symbolless();
        if (supply == 0) revert Nothing();
        salt = keccak256(abi.encode(maker, name, symbol, supply));
        home = Clones.predictDeterministicAddress(PROTOTYPE, salt, PROTOTYPE);
        deployed = home.code.length > 0;
    }

    /// @inheritdoc ICoinage
    function make(string calldata name, string calldata symbol, uint256 supply) external returns (ICoinage token) {
        (bool deployed, address home, bytes32 salt) = made(msg.sender, name, symbol, supply);
        token = ICoinage(home);
        if (deployed) {
            // return the deployed contract address.
        } else {
            home = Clones.cloneDeterministic(PROTOTYPE, salt, 0);
            Lepton(home).zzInit(msg.sender, name, symbol, supply);
        }
    }

    /// @notice Initialiser called by the prototype on a freshly deployed clone.
    /// @dev Reverts with {Unauthorized} otherwise.
    function zzInit(address maker, string calldata name, string calldata symbol, uint256 supply) public {
        if (msg.sender != PROTOTYPE) {
            revert Unauthorized();
        }
        _name = name;
        _symbol = symbol;
        _mint(maker, supply);
        emit Made(maker, ICoinage(address(this)), name, symbol, supply);
    }
}
