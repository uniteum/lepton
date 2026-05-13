// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {ERC20} from "erc20/ERC20.sol";
import {ICoinage} from "icoinage/ICoinage.sol";
import {IERC20Metadata} from "ierc20/IERC20Metadata.sol";
import {IPrototype} from "iproto/IPrototype.sol";
import {Prototype} from "proto/Prototype.sol";

/**
 * @notice Minimalist fixed-supply ERC-20 maker.
 *         Calling {make} deploys a new clone and mints the entire supply to the caller.
 * @author Paul Reinholdtsen (reinholdtsen.eth)
 */
contract Lepton is ICoinage, Prototype, ERC20 {
    string public constant version = "3.0.0";

    uint8 internal _decimals;

    constructor() ERC20("Lepton Factory", "PROTO") {
        _decimals = 18;
    }

    /**
     * @inheritdoc IERC20Metadata
     */
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /**
     * @notice Validate and ABI-encode the per-token init args.
     * @dev Reverts on empty `name`/`symbol` or zero `supply`. The returned bytes
     *      are the canonical args passed to {Prototype.make} and {zzInit}.
     */
    function encode(address maker, string calldata name, string calldata symbol, uint8 decimals_, uint256 supply)
        public
        pure
        returns (bytes memory args)
    {
        if (bytes(name).length == 0) revert Nameless();
        if (bytes(symbol).length == 0) revert Symbolless();
        if (supply == 0) revert Nothing();
        args = abi.encode(maker, name, symbol, decimals_, supply);
    }

    /**
     * @inheritdoc ICoinage
     */
    function made(
        address maker,
        string calldata name,
        string calldata symbol,
        uint8 decimals_,
        uint256 supply,
        uint256 variant
    ) external view returns (bool exists, address home, bytes32 salt) {
        (exists, home, salt) = this.made(encode(maker, name, symbol, decimals_, supply), variant);
    }

    /**
     * @inheritdoc ICoinage
     */
    function make(string calldata name, string calldata symbol, uint8 decimals_, uint256 supply, uint256 variant)
        external
        returns (IERC20Metadata token)
    {
        bytes memory args = encode(msg.sender, name, symbol, decimals_, supply);
        (bool exists, address home,) = this.make(args, variant);
        token = IERC20Metadata(home);
        if (!exists) emit Made(msg.sender, token, name, symbol, decimals_, supply, variant);
    }

    /**
     * @inheritdoc IPrototype
     * @dev Decodes `(maker, name, symbol, decimals, supply)` and mints `supply` to `maker`.
     */
    function zzInit(bytes calldata args, uint256 variant) public override {
        super.zzInit(args, variant);
        (address maker, string memory name, string memory symbol, uint8 decimals_, uint256 supply) =
            abi.decode(args, (address, string, string, uint8, uint256));
        _name = name;
        _symbol = symbol;
        _decimals = decimals_;
        _mint(maker, supply);
    }
}
