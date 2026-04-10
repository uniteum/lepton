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
    address public immutable PROTO = address(this);

    constructor() ERC20("Lepton Factory", "PROTO") {}

    /// @inheritdoc ICoinage
    function made(address maker, string calldata name, string calldata symbol, uint256 supply, bytes32 salt)
        public
        view
        returns (bool deployed, address home, bytes32 create2Salt)
    {
        if (bytes(name).length == 0) revert Nameless();
        if (bytes(symbol).length == 0) revert Symbolless();
        if (supply == 0) revert Nothing();
        create2Salt = keccak256(abi.encode(maker, name, symbol, supply, salt));
        home = Clones.predictDeterministicAddress(PROTO, create2Salt, PROTO);
        deployed = home.code.length > 0;
    }

    /// @inheritdoc ICoinage
    function make(string calldata name, string calldata symbol, uint256 supply, bytes32 salt)
        external
        returns (ICoinage token)
    {
        (bool deployed, address home, bytes32 create2Salt) = made(msg.sender, name, symbol, supply, salt);
        token = ICoinage(home);
        if (deployed) {
            // return the deployed contract address.
        } else {
            home = Clones.cloneDeterministic(PROTO, create2Salt, 0);
            Lepton(home).zzInit(msg.sender, name, symbol, supply);
        }
    }

    /// @notice Initialiser called by the prototype on a freshly deployed clone.
    /// @dev Reverts with {Unauthorized} otherwise.
    function zzInit(address maker, string calldata name, string calldata symbol, uint256 supply) public {
        if (msg.sender != PROTO) revert Unauthorized();
        _name = name;
        _symbol = symbol;
        _mint(maker, supply);
        emit Made(maker, ICoinage(address(this)), name, symbol, supply);
    }
}
