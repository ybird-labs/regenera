// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { console2 } from "forge-std/console2.sol";

import { BaseConfigScript } from "script/BaseConfig.s.sol";

contract ValidateConfigScript is BaseConfigScript {
    function run() external view {
        DeployConfig memory cfg = loadConfig();

        require(bytes(cfg.network).length != 0, "missing network");
        require(cfg.chainId != 0, "missing chainId");
        require(cfg.admin != address(0), "missing admin");
        require(cfg.safe != address(0), "missing safe");
        require(cfg.treasury != address(0), "missing treasury");

        console2.log("config path", configPath());
        console2.log("network", cfg.network);
        console2.log("chain id", cfg.chainId);
        console2.log("admin", cfg.admin);
        console2.log("safe", cfg.safe);
        console2.log("treasury", cfg.treasury);
        console2.log("verify", cfg.verify);
    }
}
