// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract Vault is ERC20, Ownable {
    address public assetToken;

    error AmountCannotBeZero();

    event Deposit(address indexed sender, uint256 amount, uint256 shares);
    event Withdraw(address indexed sender, uint256 amount, uint256 shares);

    constructor(address _assetToken) ERC20("Vault", "VAULT") Ownable(msg.sender) {
        assetToken = _assetToken;
    }

    function deposit(uint256 amount) public {
        //jika amount adalah 0, maka revert
        if(amount == 0) revert AmountCannotBeZero();

        uint256 shares = 0;
        uint256 totalAssets = IERC20(assetToken).balanceOf(address(this));
        //jika totalSupply adalah 0, maka shares adalah amount
        if(totalSupply() == 0) {
            shares = amount;
        } else {
            //jika totalSupply tidak 0, maka shares adalah amount * totalSupply / totalAssets
            shares = amount * totalSupply() / totalAssets;
        }

        //mint shares ke msg.sender
        _mint(msg.sender, shares);
        //transfer amount dari msg.sender ke address(this)
        IERC20(assetToken).transferFrom(msg.sender, address(this), amount);
        emit Deposit(msg.sender, amount, shares);
    }

    function withdraw(uint256 shares) external {
      uint256 totalAssets = IERC20(assetToken).balanceOf(address(this));
      uint256 amount = (shares * totalAssets) / totalSupply();

      _burn(msg.sender, shares);
      IERC20(assetToken).transfer(msg.sender, amount);

      emit Withdraw(msg.sender, amount, shares);
    }

    function distributeYield(uint256 amount) external onlyOwner{
      IERC20(assetToken).transferFrom(msg.sender, address(this), amount);
    }
}
