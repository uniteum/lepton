// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {User} from "crucible/test/User.sol";
import {Lepton} from "../src/Lepton.sol";

contract LeptonUser is User {
    Lepton public immutable LEPTON;

    constructor(string memory name_, Lepton leptonProtype) User(name_) {
        LEPTON = leptonProtype;
    }

    function newLepton(
        Lepton lepton,
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 supply,
        bytes32 salt
    ) public returns (Lepton token) {
        token = Lepton(address(lepton.make(name_, symbol_, decimals_, supply, salt)));
        addToken(token);
    }

    function newLepton(Lepton lepton, string memory name_, string memory symbol_, uint8 decimals_, uint256 supply)
        public
        returns (Lepton token)
    {
        token = newLepton(lepton, name_, symbol_, decimals_, supply, bytes32(0));
    }

    function newLepton(string memory name_, string memory symbol_, uint8 decimals_, uint256 supply)
        public
        returns (Lepton token)
    {
        token = newLepton(LEPTON, name_, symbol_, decimals_, supply, bytes32(0));
    }
}
