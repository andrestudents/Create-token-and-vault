// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BahlilToken} from "../src/Bahlil.sol";

contract BahlilTokenTest is Test {
    BahlilToken public token;
    address public owner = address(this);
    address public alice = address(0x1);
    address public bob = address(0x2);

    function setUp() public {
        token = new BahlilToken();
    }

    function test_Deployment() public view {
        assertEq(token.name(), "BahlilToken");
        assertEq(token.symbol(), "BAHLIL");
        assertEq(token.totalSupply(), 0);
        assertEq(token.owner(), owner);
    }

    function test_Mint() public {
        uint256 mintAmount = 1000e18;

        token.mint(alice, mintAmount);

        assertEq(token.balanceOf(alice), mintAmount);
        assertEq(token.totalSupply(), mintAmount);
    }

    function test_MintMultipleAddresses() public {
        uint256 mintAmount1 = 1000e18;
        uint256 mintAmount2 = 500e18;

        token.mint(alice, mintAmount1);
        token.mint(bob, mintAmount2);

        assertEq(token.balanceOf(alice), mintAmount1);
        assertEq(token.balanceOf(bob), mintAmount2);
        assertEq(token.totalSupply(), mintAmount1 + mintAmount2);
    }

    function test_Burn() public {
        uint256 mintAmount = 1000e18;
        uint256 burnAmount = 300e18;

        token.mint(alice, mintAmount);
        token.burn(alice, burnAmount);

        assertEq(token.balanceOf(alice), mintAmount - burnAmount);
        assertEq(token.totalSupply(), mintAmount - burnAmount);
    }

    function test_BurnEntireBalance() public {
        uint256 mintAmount = 1000e18;

        token.mint(alice, mintAmount);
        token.burn(alice, mintAmount);

        assertEq(token.balanceOf(alice), 0);
        assertEq(token.totalSupply(), 0);
    }
}
