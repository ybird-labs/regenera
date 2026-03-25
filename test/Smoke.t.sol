// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";

import {Smoke} from "src/Smoke.sol";

contract SmokeTest is Test {
    Smoke internal smoke;

    function setUp() public {
        smoke = new Smoke();
    }

    function test_DefaultValueIsZero() public view {
        assertEq(smoke.getValue(), 0);
    }

    function test_SetValueUpdatesState() public {
        smoke.setValue(42);

        assertEq(smoke.getValue(), 42);
    }

    function testFuzz_SetValue(uint256 newValue) public {
        smoke.setValue(newValue);

        assertEq(smoke.getValue(), newValue);
    }
}
