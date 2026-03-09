// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {BaseTest} from "./Base.t.sol";
import {LeptonUser} from "./LeptonUser.sol";
import {Lepton} from "../src/Lepton.sol";
import {ICoinage} from "../src/ICoinage.sol";

contract LeptonTest is BaseTest {
    uint256 constant TOTAL_SUPPLY_1 = 1 ether;
    string constant TOKEN_NAME_1 = "First";
    string constant TOKEN_SYMBOL_1 = "FIRST";
    uint256 constant TOTAL_SUPPLY_2 = 2 ether;
    string constant TOKEN_NAME_2 = "Second";
    string constant TOKEN_SYMBOL_2 = "SECOND";
    string constant USER_NAME = "LeptonUser";
    Lepton public leptonPrototype;
    LeptonUser public leptonUser;

    function setUp() public virtual override {
        leptonPrototype = new Lepton{salt: 0x0}();
        leptonUser = newLeptonUser();
    }

    function newLeptonUser() public returns (LeptonUser user) {
        user = new LeptonUser(USER_NAME, leptonPrototype);
    }

    function test_NewLepton() public returns (Lepton lepton1) {
        lepton1 = leptonUser.newLepton(TOKEN_NAME_1, TOKEN_SYMBOL_1, TOTAL_SUPPLY_1);
        assertEq(lepton1.name(), TOKEN_NAME_1);
        assertEq(lepton1.symbol(), TOKEN_SYMBOL_1);
        assertEq(lepton1.totalSupply(), TOTAL_SUPPLY_1, "total supply");
        assertEq(lepton1.balanceOf(address(leptonUser)), TOTAL_SUPPLY_1, "balance of creator");
    }

    function test_CreateIdempotent() public returns (Lepton lepton1, Lepton lepton2) {
        lepton1 = leptonUser.newLepton(TOKEN_NAME_1, TOKEN_SYMBOL_1, TOTAL_SUPPLY_1);
        lepton2 = leptonUser.newLepton(TOKEN_NAME_1, TOKEN_SYMBOL_1, TOTAL_SUPPLY_1);
        assertEq(address(lepton1), address(lepton2), "lepton create not idempotent");
        assertEq(lepton1.balanceOf(address(leptonUser)), TOTAL_SUPPLY_1, "balance of creator");
    }

    function test_SelfCreateIdempotent() public returns (Lepton lepton1, Lepton lepton2) {
        lepton1 = leptonUser.newLepton(TOKEN_NAME_1, TOKEN_SYMBOL_1, TOTAL_SUPPLY_1);
        lepton2 = leptonUser.newLepton(lepton1, TOKEN_NAME_1, TOKEN_SYMBOL_1, TOTAL_SUPPLY_1);
        assertEq(address(lepton1), address(lepton2), "lepton create not idempotent");
    }

    function test_OutsideInitializeReverts() public returns (Lepton lepton1) {
        lepton1 = leptonUser.newLepton(TOKEN_NAME_1, TOKEN_SYMBOL_1, TOTAL_SUPPLY_1);
        vm.expectRevert(ICoinage.Unauthorized.selector);
        lepton1.zzz_(address(leptonUser), TOKEN_NAME_1, TOKEN_SYMBOL_1, TOTAL_SUPPLY_1);
    }
}
