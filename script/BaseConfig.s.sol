// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";

abstract contract BaseConfigScript is Script {
    using stdJson for string;

    struct DeployConfig {
        string network;
        uint256 chainId;
        address admin;
        address safe;
        address treasury;
        bool verify;
    }

    function configPath() internal view returns (string memory) {
        return vm.envOr("CONFIG_PATH", string("config/local.json"));
    }

    function loadConfig() internal view returns (DeployConfig memory cfg) {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/", configPath());
        string memory json = vm.readFile(path);

        cfg.network = json.readString(".network");
        cfg.chainId = json.readUint(".chainId");
        cfg.admin = json.readAddress(".admin");
        cfg.safe = json.readAddress(".safe");
        cfg.treasury = json.readAddress(".treasury");
        cfg.verify = json.readBool(".verify");
    }
}
