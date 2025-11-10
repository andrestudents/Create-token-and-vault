// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("MockERC20", "MOCK") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract VaultTest is Test {
    Vault public vault;
    MockERC20 public mockERC20;
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");

    function setUp() public {
        mockERC20 = new MockERC20();
        vault = new Vault(address(mockERC20));

        mockERC20.mint(user1, 1000);
        mockERC20.mint(user2, 2000);
    }

    function test_Deposit() public {
        vm.startPrank(user1);
        uint256 beforeBalance = mockERC20.balanceOf(user1);
        console.log("user1 balance before deposit: ", beforeBalance);
        mockERC20.approve(address(vault), 100);
        vault.deposit(100);
        uint256 afterBalance = mockERC20.balanceOf(user1);
        console.log("user1 balance after deposit: ", afterBalance);
        vm.stopPrank();
    }

    function test_withdraw() public {
        vm.startPrank(user1);
        mockERC20.approve(address(vault), 50);
        vault.deposit(50);
        vault.withdraw(50);
        assertEq(vault.totalSupply(), 0);
        assertEq(vault.balanceOf(user1), 0);
        vm.stopPrank();
    }
}
