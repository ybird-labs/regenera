// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract Smoke {
    uint256 private value;

    event ValueUpdated(uint256 value_);

    function setValue(uint256 newValue) external {
        value = newValue;
        emit ValueUpdated(newValue);
    }

    function getValue() external view returns (uint256) {
        return value;
    }
}
