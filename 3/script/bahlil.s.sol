 // // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Script} from "forge-std/Script.sol";
// import {BahlilToken} from "../src/bahlil.sol";

// contract BahlilScript is Script {
//     BahlilToken public bahlil;

//     function run() public returns (address) {
//         uint256 privateKey = vm.envUint("PRIVATE_KEY");
//         vm.startBroadcast(privateKey);

//         bahlil = new BahlilToken();

//         vm.stopBroadcast();

//         return address(bahlil);
//     }
// }
