// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Vault} from "src/Vault.sol";
import {BahlilToken} from "src/Bahlil.sol";

contract DeployVault is Script {
    Vault public vault;
    BahlilToken public bahlil;

    function run() public returns (address) {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        bahlil = new BahlilToken();

        vault = new Vault(address(bahlil));

        vm.stopBroadcast();
        return address(vault);
    }
}
