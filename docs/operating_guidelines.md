# Operating Guidelines for KCD2 Gear Picker

## General Principles

When working with this repository, the following guidelines should be followed:

1. **Documentation First:** Always review the documentation in the `/docs` folder before making changes to understand the current state and goals of the project.

2. **Keep Documentation Updated:** Any change to the codebase should be accompanied by appropriate updates to the documentation files to maintain an accurate representation of how the codebase works and our implementation plans.

3. **Single Mod Approach:** Unlike the original "Helmet Off Dialog" mod which had multiple optional modules, the "Gear Picker" mod will be implemented as a single mod with integrated optimization features.

4. **Reference Code:** The code in `src/helmet_only/`, `src/random/`, and `src/ranged/` is kept for reference purposes only and should not be modified or used in our implementation. Our focus is exclusively on extending and modifying the code in `src/main/`.

## File Organization

- `/docs/`: Contains all documentation files:
  - `current_functionality.md`: Documents how the original code works
  - `implementation_plan.md`: Outlines our plans for implementation
  - `development_progress.md`: Tracks our progress
  - `operating_guidelines.md`: This file - contains operational rules

- `/src/main/`: Contains the core code we'll be modifying
- `/src/helmet_only/`, `/src/random/`, `/src/ranged/`: Reference code only, not to be used

## Documentation Update Guidelines

When making changes to the codebase, ensure that the following files are updated accordingly:

1. **For new features or significant changes:**
   - Update `implementation_plan.md` with the approach
   - Add details to `current_functionality.md` once implemented
   - Update `development_progress.md` to reflect the change in progress

2. **For bug fixes or minor changes:**
   - Add a note to `development_progress.md`

3. **For major architectural decisions:**
   - Document in all three main documentation files
   - Consider adding a new documentation file if required

## Version Tracking

- The mod version is tracked in `src/main/mod.manifest`
- Version numbering follows Semantic Versioning (MAJOR.MINOR.PATCH)
- Update the version number when appropriate:
  - MAJOR: incompatible API changes
  - MINOR: add functionality in a backward-compatible manner
  - PATCH: backward-compatible bug fixes

## Commit Guidelines

- Use clear, descriptive commit messages
- Reference documentation updates in commits
- Ensure all tests pass before committing

These guidelines ensure that our documentation always represents an accurate picture of the codebase and our development strategy.