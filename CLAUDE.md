# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

KCD2 Gear Picker is a mod for Kingdom Come Deliverance 2 that helps optimize gear selection for different scenarios:
- Maximum Armor/Protection
- Maximum Stealth
- Maximum Charisma

The mod uses a direct item scanning approach, focusing on collecting comprehensive stats for all equippable gear items, regardless of whether they're currently equipped.

## Repository Structure

- `/src/main/`: Contains the core implementation files that we'll be modifying
- `/src/helmet_only/`, `/src/random/`, `/src/ranged/`: Reference code only (not to be used in implementation)
- `/docs/`: Documentation files with implementation details and progress tracking
- `/tests/`: Contains unit tests for the mod

## Development Commands

```bash
# Development build
npm run dev

# Production build
npm run prod

# Code formatting check
npm run prettier

# Fix formatting issues
npm run prettier:fix

# Generate readme
npm run generate_readme
```

## Code Architecture

The mod follows a modular architecture with these key components:

1. **HelmetOffDialog**: Main class that initializes the mod and provides factory methods for other components.

2. **Equipment**: Manages tracking of equipped gear and handles equipping/unequipping.

3. **UnequipGear**: Core module that handles detection and removal of gear.

4. **ItemScanner**: Implements a direct inventory scanning approach:
   - Retrieves all items from player inventory
   - Filters for equippable armor/clothing items
   - Collects comprehensive stats for each item (defense, stealth, charisma, etc.)
   - Uses name patterns and stat profiles to categorize items by type

5. **ItemCategory**: Defines different item categories (Helmet, HeadChainmail, Coif, etc.) and provides methods to check if items belong to specific categories.

6. **Config**: Manages mod settings and configuration options.

The mod uses a factory pattern extensively, with the main HelmetOffDialog class acting as the central entry point that initializes and connects all components.

## Important Guidelines

1. Focus implementation exclusively on the code in `/src/main/` directory
2. Keep all documentation in `/docs/` updated when making code changes
3. The mod uses a single integrated approach rather than multiple optional modules
4. Always run tests to verify functionality before committing changes
5. Update version information in `src/main/mod.manifest` when appropriate

Refer to `/docs/operating_guidelines.md` for complete development guidelines.