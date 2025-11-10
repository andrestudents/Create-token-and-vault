# Solidity Smart Contracts Collection

This repository contains three different iterations/versions of Solidity smart contract projects, all built using the Foundry development framework. The projects focus on implementing ERC20 tokens and vault contracts for managing token deposits and rewards.

## Repository Structure

```
Batch 5/
├── 1/          # Complete implementation with comprehensive tests
├── 2/          # Implementation with deployment scripts
└── 3/          # Alternative implementation (dw3v-day2 subdirectory)
```

---

## Project 1: Full Implementation with Tests

**Location:** `1/`

This is the most complete version with comprehensive test coverage.

### Contracts

#### BahlilToken (`src/Bahlil.sol:7`)
- **Type:** ERC20 Token
- **Name:** BahlilToken
- **Symbol:** BAHLIL
- **Features:**
  - Inherits from OpenZeppelin's ERC20 and Ownable
  - Public `mint()` function - allows minting tokens to any address
  - Public `burn()` function - allows burning tokens from any address
  - Owner assigned to contract deployer

#### Vault (`src/Vault.sol:11`)
- **Type:** ERC20 Token Vault
- **Name:** Vault
- **Symbol:** VAULT
- **Features:**
  - Manages deposits of an underlying ERC20 asset token
  - Issues shares proportional to deposits
  - Share calculation mechanism that accounts for rewards
  - Uses SafeERC20 for secure token transfers
  - Owner-only reward distribution function

**Key Functions:**
- `deposit(uint256 amount)` - Deposit asset tokens, receive vault shares (1/src/Vault.sol:27)
- `withdraw(uint256 shares)` - Burn shares to withdraw asset tokens (1/src/Vault.sol:47)
- `distributeRewards(uint256 amount)` - Owner can add rewards to the vault (1/src/Vault.sol:54)
- `totalAssets()` - Returns total asset tokens held by vault (1/src/Vault.sol:58)

**Share Calculation Logic:**
- First deposit: shares = amount (1:1 ratio)
- Subsequent deposits: shares = (amount * totalSupply) / totalAssets
- This allows rewards to increase the value of existing shares

### Tests

#### BahlilToken Tests (`test/Bahlil.t.sol`)
- Deployment verification
- Minting functionality (single and multiple addresses)
- Burning functionality (partial and complete)

#### Vault Tests (`test/Vault.t.sol`)
- Deployment verification
- First deposit and share calculation
- Multiple deposits from different users
- Zero amount deposit revert test
- Withdraw functionality (partial and complete)
- Reward distribution (owner-only)
- Share value calculation after rewards
- Event emission tests

### Deployment Script
- `script/Deploy.s.sol` - Appears to be empty/minimal

---

## Project 2: Implementation with Deployment Scripts

**Location:** `2/`

Similar structure to Project 1 but with deployment scripts instead of extensive tests.

### Contracts

#### BahlilToken (`src/Bahlil.sol:7`)
- Identical implementation to Project 1
- Uses OpenZeppelin imports with `@openzeppelin` alias

#### Vault (`src/Vault.sol`)
- File appears to be empty or minimal (only 1 line)
- Likely incomplete or in development

### Deployment Scripts

#### DeployVault Script (`script/Vault.s.sol:8`)
- Deploys both BahlilToken and Vault contracts
- Uses environment variable `PRIVATE_KEY` for deployment
- Returns the deployed Vault address
- Integrated with Foundry's scripting system

#### Bahlil Script (`script/Bahlil.s.sol`)
- File appears to be empty or minimal

---

## Project 3: Alternative Implementation (dw3v-day2)

**Location:** `3/dw3v-day2/`

This version contains some notable differences from Projects 1 and 2.

### Contracts

#### BahlilToken (`src/bahlil.sol:7`)
- **Key Difference:** Custom decimals implementation
- Overrides `decimals()` to return 1 instead of default 18 (3/dw3v-day2/src/bahlil.sol:17)
- Otherwise identical to other implementations

#### Vault (`src/Vault.sol:8`)
- **Key Differences:**
  - Does NOT use SafeERC20 wrapper (uses direct IERC20 calls)
  - Function renamed: `distributeYield()` instead of `distributeRewards()` (3/dw3v-day2/src/Vault.sol:51)
  - Inline calculation of `totalAssets` in functions rather than separate view function
  - Similar core logic but potentially less secure without SafeERC20

**Security Note:** This implementation uses standard `transfer()` and `transferFrom()` without SafeERC20, which could be problematic with non-standard ERC20 tokens.

---

## Technology Stack

All projects use:
- **Solidity** ^0.8.13
- **Foundry** - Development framework
  - **Forge** - Testing framework
  - **Cast** - CLI tool for blockchain interaction
  - **Anvil** - Local Ethereum node
- **OpenZeppelin Contracts** - Standard library for secure smart contracts

---

## Common Usage Commands

### Build
```shell
forge build
```

### Test
```shell
forge test
```

### Deploy (Project 2)
```shell
forge script script/Vault.s.sol:DeployVault --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Gas Snapshots
```shell
forge snapshot
```

### Local Development
```shell
anvil
```

---

## Core Concepts Implemented

### Vault Mechanics
The vault implements a share-based system where:
1. Users deposit asset tokens and receive shares
2. Share value increases when rewards are distributed
3. Users can redeem shares for the underlying assets proportional to their share

### Formula
```
shares = (depositAmount * totalSupply) / totalAssets
withdrawAmount = (shares * totalAssets) / totalSupply
```

### Reward Distribution
When the owner distributes rewards, the total assets increase without increasing total supply, making each share more valuable.

---

## Security Considerations

### Project 1
- Uses SafeERC20 for secure transfers
- Comprehensive test coverage
- Checks for zero amount deposits

### Project 2
- Incomplete implementation (Vault.sol appears empty)
- Has deployment script ready

### Project 3
- **Risk:** Does not use SafeERC20
- **Risk:** Custom decimals (1) could cause calculation issues
- **Risk:** No access control on mint/burn functions in BahlilToken

---

## Version Comparison Summary

| Feature | Project 1 | Project 2 | Project 3 |
|---------|-----------|-----------|-----------|
| Comprehensive Tests | ✅ | ❌ | ❌ |
| Deployment Scripts | ❌ | ✅ | ❌ |
| SafeERC20 | ✅ | N/A | ❌ |
| Custom Decimals | ❌ | ❌ | ✅ (1 decimal) |
| Complete Implementation | ✅ | ⚠️ (Vault empty) | ✅ |

---

## License

All projects: UNLICENSED

## Additional Resources

- [Foundry Documentation](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
