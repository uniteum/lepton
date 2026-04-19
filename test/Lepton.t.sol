// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {BaseTest} from "crucible/test/Base.t.sol";
import {LeptonUser} from "./LeptonUser.sol";
import {Lepton} from "../src/Lepton.sol";
import {ICoinage} from "ierc20/ICoinage.sol";
import {IERC20Metadata} from "ierc20/IERC20Metadata.sol";
import {Vm} from "forge-std/Vm.sol";

contract LeptonTest is BaseTest {
    uint256 constant TOTAL_SUPPLY_1 = 1 ether;
    string constant TOKEN_NAME_1 = "First";
    string constant TOKEN_SYMBOL_1 = "FIRST";
    uint8 constant TOKEN_DECIMALS_1 = 18;
    uint256 constant TOTAL_SUPPLY_2 = 2 ether;
    string constant TOKEN_NAME_2 = "Second";
    string constant TOKEN_SYMBOL_2 = "SECOND";
    uint8 constant TOKEN_DECIMALS_2 = 6;
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
        lepton1 = leptonUser.newLepton(TOKEN_NAME_1, TOKEN_SYMBOL_1, TOKEN_DECIMALS_1, TOTAL_SUPPLY_1);
        assertEq(lepton1.name(), TOKEN_NAME_1);
        assertEq(lepton1.symbol(), TOKEN_SYMBOL_1);
        assertEq(lepton1.decimals(), TOKEN_DECIMALS_1, "decimals");
        assertEq(lepton1.totalSupply(), TOTAL_SUPPLY_1, "total supply");
        assertEq(lepton1.balanceOf(address(leptonUser)), TOTAL_SUPPLY_1, "balance of creator");
    }

    function test_NewLeptonCustomDecimals() public returns (Lepton lepton2) {
        lepton2 = leptonUser.newLepton(TOKEN_NAME_2, TOKEN_SYMBOL_2, TOKEN_DECIMALS_2, TOTAL_SUPPLY_2);
        assertEq(lepton2.decimals(), TOKEN_DECIMALS_2, "decimals");
    }

    function test_DecimalsSegregateCreate2() public {
        Lepton lepton18 = leptonUser.newLepton(TOKEN_NAME_1, TOKEN_SYMBOL_1, TOKEN_DECIMALS_1, TOTAL_SUPPLY_1);
        Lepton lepton6 = leptonUser.newLepton(TOKEN_NAME_1, TOKEN_SYMBOL_1, TOKEN_DECIMALS_2, TOTAL_SUPPLY_1);
        assertTrue(address(lepton18) != address(lepton6), "same address for different decimals");
        assertEq(lepton18.decimals(), TOKEN_DECIMALS_1);
        assertEq(lepton6.decimals(), TOKEN_DECIMALS_2);
    }

    function test_PrototypeDecimals() public view {
        assertEq(leptonPrototype.decimals(), 18, "prototype decimals");
    }

    function test_CreateIdempotent() public returns (Lepton lepton1, Lepton lepton2) {
        lepton1 = leptonUser.newLepton(TOKEN_NAME_1, TOKEN_SYMBOL_1, TOKEN_DECIMALS_1, TOTAL_SUPPLY_1);
        lepton2 = leptonUser.newLepton(TOKEN_NAME_1, TOKEN_SYMBOL_1, TOKEN_DECIMALS_1, TOTAL_SUPPLY_1);
        assertEq(address(lepton1), address(lepton2), "lepton create not idempotent");
        assertEq(lepton1.balanceOf(address(leptonUser)), TOTAL_SUPPLY_1, "balance of creator");
    }

    function test_SelfCreateIdempotent() public returns (Lepton lepton1, Lepton lepton2) {
        lepton1 = leptonUser.newLepton(TOKEN_NAME_1, TOKEN_SYMBOL_1, TOKEN_DECIMALS_1, TOTAL_SUPPLY_1);
        lepton2 = leptonUser.newLepton(lepton1, TOKEN_NAME_1, TOKEN_SYMBOL_1, TOKEN_DECIMALS_1, TOTAL_SUPPLY_1);
        assertEq(address(lepton1), address(lepton2), "lepton create not idempotent");
    }

    function test_OutsideInitializeReverts() public returns (Lepton lepton1) {
        lepton1 = leptonUser.newLepton(TOKEN_NAME_1, TOKEN_SYMBOL_1, TOKEN_DECIMALS_1, TOTAL_SUPPLY_1);
        vm.expectRevert(ICoinage.Unauthorized.selector);
        lepton1.zzInit(address(leptonUser), TOKEN_NAME_1, TOKEN_SYMBOL_1, TOKEN_DECIMALS_1, TOTAL_SUPPLY_1);
    }

    function test_RevertNameless() public {
        vm.expectRevert(ICoinage.Nameless.selector);
        leptonPrototype.make("", TOKEN_SYMBOL_1, TOKEN_DECIMALS_1, TOTAL_SUPPLY_1, bytes32(0));
    }

    function test_RevertSymbolless() public {
        vm.expectRevert(ICoinage.Symbolless.selector);
        leptonPrototype.make(TOKEN_NAME_1, "", TOKEN_DECIMALS_1, TOTAL_SUPPLY_1, bytes32(0));
    }

    function test_RevertNothing() public {
        vm.expectRevert(ICoinage.Nothing.selector);
        leptonPrototype.make(TOKEN_NAME_1, TOKEN_SYMBOL_1, TOKEN_DECIMALS_1, 0, bytes32(0));
    }

    function test_MadeEventOnCreationOnly() public {
        (, address home,) = leptonPrototype.made(
            address(leptonUser), TOKEN_NAME_1, TOKEN_SYMBOL_1, TOKEN_DECIMALS_1, TOTAL_SUPPLY_1, bytes32(0)
        );

        vm.expectEmit(true, true, false, true, address(leptonPrototype));
        emit ICoinage.Made(
            address(leptonUser), IERC20Metadata(home), TOKEN_NAME_1, TOKEN_SYMBOL_1, TOKEN_DECIMALS_1, TOTAL_SUPPLY_1
        );
        leptonUser.newLepton(TOKEN_NAME_1, TOKEN_SYMBOL_1, TOKEN_DECIMALS_1, TOTAL_SUPPLY_1);

        vm.recordLogs();
        leptonUser.newLepton(TOKEN_NAME_1, TOKEN_SYMBOL_1, TOKEN_DECIMALS_1, TOTAL_SUPPLY_1);
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 madeTopic = keccak256("Made(address,address,string,string,uint8,uint256)");
        for (uint256 i = 0; i < entries.length; i++) {
            assertTrue(entries[i].topics[0] != madeTopic, "Made emitted on idempotent make");
        }
    }
}
