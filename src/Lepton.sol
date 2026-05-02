// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ICoinage} from "icoinage/ICoinage.sol";
import {IERC20Metadata} from "ierc20/IERC20Metadata.sol";
import {ERC20} from "erc20/ERC20.sol";
import {Clones} from "clones/Clones.sol";

/**
 * @notice Minimalist fixed-supply ERC-20 maker.
 *         Calling {make} deploys a new clone and mints the entire supply to the caller.
 * @author Paul Reinholdtsen (reinholdtsen.eth)
 */
contract Lepton is ICoinage, ERC20 {
    string public constant version = "1.0.0";

    /// @notice The prototype instance used as the EIP-1167 implementation.
    address public immutable proto = address(this);

    uint8 internal _decimals;

    constructor() ERC20("Lepton Factory", "PROTO") {
        _decimals = 18;
    }

    /// @inheritdoc IERC20Metadata
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /// @inheritdoc ICoinage
    function made(
        address maker,
        string calldata name,
        string calldata symbol,
        uint8 decimals_,
        uint256 supply,
        uint256 variant
    ) public view returns (bool deployed, address home, bytes32 salt) {
        if (bytes(name).length == 0) revert Nameless();
        if (bytes(symbol).length == 0) revert Symbolless();
        if (supply == 0) revert Nothing();
        salt = keccak256(abi.encode(maker, name, symbol, decimals_, supply, variant));
        home = Clones.predictDeterministicAddress(proto, salt, proto);
        deployed = home.code.length > 0;
    }

    /// @inheritdoc ICoinage
    function make(string calldata name, string calldata symbol, uint8 decimals_, uint256 supply, uint256 variant)
        external
        returns (IERC20Metadata token)
    {
        (bool deployed, address home, bytes32 salt) = made(msg.sender, name, symbol, decimals_, supply, variant);
        token = IERC20Metadata(home);
        if (deployed) {
            // return the deployed contract address.
        } else {
            home = Clones.cloneDeterministic(proto, salt, 0);
            Lepton(home).zzInit(msg.sender, name, symbol, decimals_, supply);
            emit Made(msg.sender, token, name, symbol, decimals_, supply);
        }
    }

    /**
     * @notice Initialiser called by the prototype on a freshly deployed clone.
     * @dev Reverts with {Unauthorized} otherwise.
     */
    function zzInit(address maker, string calldata name, string calldata symbol, uint8 decimals_, uint256 supply)
        public
    {
        if (msg.sender != proto) revert Unauthorized();
        _name = name;
        _symbol = symbol;
        _decimals = decimals_;
        _mint(maker, supply);
    }
}
