// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";
import {BahlilToken} from "../src/Bahlil.sol";

contract VaultTest is Test {
    Vault public vault;
    BahlilToken public assetToken;

    address public owner = address(this);
    address public alice = address(0x1);
    address public bob = address(0x2);

    function setUp() public {
        assetToken = new BahlilToken();
        vault = new Vault(address(assetToken));

        // Mint tokens to alice and bob for testing
        assetToken.mint(alice, 10000e18);
        assetToken.mint(bob, 10000e18);
    }

    function test_Deployment() public view {
        assertEq(vault.name(), "Vault");
        assertEq(vault.symbol(), "VAULT");
        assertEq(vault.assetToken(), address(assetToken));
        assertEq(vault.totalSupply(), 0);
        assertEq(vault.owner(), owner);
    }

    function test_DepositFirstDeposit() public {
        uint256 depositAmount = 1000e18;

        vm.startPrank(alice);
        assetToken.approve(address(vault), depositAmount);
        vault.deposit(depositAmount);
        vm.stopPrank();

        assertEq(vault.balanceOf(alice), depositAmount);
        assertEq(vault.totalSupply(), depositAmount);
        assertEq(vault.totalAssets(), depositAmount);
        assertEq(assetToken.balanceOf(alice), 10000e18 - depositAmount);
    }

    function test_DepositMultipleDeposits() public {
        uint256 depositAmount1 = 1000e18;
        uint256 depositAmount2 = 500e18;

        // Alice deposits first
        vm.startPrank(alice);
        assetToken.approve(address(vault), depositAmount1);
        vault.deposit(depositAmount1);
        vm.stopPrank();

        // Bob deposits second
        vm.startPrank(bob);
        assetToken.approve(address(vault), depositAmount2);
        vault.deposit(depositAmount2);
        vm.stopPrank();

        assertEq(vault.balanceOf(alice), depositAmount1);
        assertEq(vault.balanceOf(bob), depositAmount2);
        assertEq(vault.totalSupply(), depositAmount1 + depositAmount2);
        assertEq(vault.totalAssets(), depositAmount1 + depositAmount2);
    }

    function test_DepositRevertZeroAmount() public {
        vm.startPrank(alice);
        vm.expectRevert(Vault.AmountCannotBeZero.selector);
        vault.deposit(0);
        vm.stopPrank();
    }

    function test_DepositEmitEvent() public {
        uint256 depositAmount = 1000e18;

        vm.startPrank(alice);
        assetToken.approve(address(vault), depositAmount);

        vm.expectEmit(true, false, false, true);
        emit Vault.Deposit(alice, depositAmount, depositAmount);
        vault.deposit(depositAmount);
        vm.stopPrank();
    }

    function test_Withdraw() public {
        uint256 depositAmount = 1000e18;

        // Alice deposits
        vm.startPrank(alice);
        assetToken.approve(address(vault), depositAmount);
        vault.deposit(depositAmount);

        uint256 sharesToWithdraw = 500e18;
        vault.withdraw(sharesToWithdraw);
        vm.stopPrank();

        assertEq(vault.balanceOf(alice), depositAmount - sharesToWithdraw);
        assertEq(assetToken.balanceOf(alice), 10000e18 - depositAmount + sharesToWithdraw);
        assertEq(vault.totalSupply(), depositAmount - sharesToWithdraw);
    }

    function test_WithdrawAll() public {
        uint256 depositAmount = 1000e18;

        // Alice deposits
        vm.startPrank(alice);
        assetToken.approve(address(vault), depositAmount);
        vault.deposit(depositAmount);

        vault.withdraw(depositAmount);
        vm.stopPrank();

        assertEq(vault.balanceOf(alice), 0);
        assertEq(assetToken.balanceOf(alice), 10000e18);
        assertEq(vault.totalSupply(), 0);
    }

    function test_WithdrawEmitEvent() public {
        uint256 depositAmount = 1000e18;

        vm.startPrank(alice);
        assetToken.approve(address(vault), depositAmount);
        vault.deposit(depositAmount);

        vm.expectEmit(true, false, false, true);
        emit Vault.Withdraw(alice, depositAmount, depositAmount);
        vault.withdraw(depositAmount);
        vm.stopPrank();
    }

    function test_DistributeRewards() public {
        uint256 depositAmount = 1000e18;
        uint256 rewardAmount = 100e18;

        // Alice deposits
        vm.startPrank(alice);
        assetToken.approve(address(vault), depositAmount);
        vault.deposit(depositAmount);
        vm.stopPrank();

        // Owner distributes rewards
        assetToken.mint(owner, rewardAmount);
        assetToken.approve(address(vault), rewardAmount);
        vault.distributeRewards(rewardAmount);

        assertEq(vault.totalAssets(), depositAmount + rewardAmount);
    }

    function test_DistributeRewardsOnlyOwner() public {
        uint256 rewardAmount = 100e18;

        vm.startPrank(alice);
        assetToken.approve(address(vault), rewardAmount);
        vm.expectRevert();
        vault.distributeRewards(rewardAmount);
        vm.stopPrank();
    }

    function test_TotalAssets() public {
        assertEq(vault.totalAssets(), 0);

        uint256 depositAmount = 1000e18;
        vm.startPrank(alice);
        assetToken.approve(address(vault), depositAmount);
        vault.deposit(depositAmount);
        vm.stopPrank();

        assertEq(vault.totalAssets(), depositAmount);
    }

    function test_SharesCalculationAfterRewards() public {
        // Alice deposits 1000 tokens, gets 1000 shares
        vm.startPrank(alice);
        assetToken.approve(address(vault), 1000e18);
        vault.deposit(1000e18);
        vm.stopPrank();

        // Owner adds 100 tokens as rewards
        assetToken.mint(owner, 100e18);
        assetToken.approve(address(vault), 100e18);
        vault.distributeRewards(100e18);

        // Now totalAssets = 1100, totalSupply = 1000
        // Bob deposits 550 tokens, should get 500 shares (550 * 1000 / 1100 = 500)
        vm.startPrank(bob);
        assetToken.approve(address(vault), 550e18);
        vault.deposit(550e18);
        vm.stopPrank();

        assertEq(vault.balanceOf(bob), 500e18);
        assertEq(vault.totalAssets(), 1650e18);
    }
}
