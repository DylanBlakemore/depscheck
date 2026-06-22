# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.13] - 2026-06-22

### Fixed

- Greatly expanded the recognized license catalogue across all categories:
- Permissive: added MIT-0, X11, Apache-1.1, BSD-4-Clause, BSD-3-Clause-Clear, BSL-1.0 (Boost), Zlib, NCSA, MS-PL, PostgreSQL, Python-2.0, PSF-2.0, Artistic-2.0, WTFPL, UPL-1.0, OFL-1.1, Vim, BlueOak-1.0.0, AFL-3.0, ECL-2.0, MulanPSL-2.0, CC-BY-4.0.
- Strong copyleft: added GPL-1.0, EUPL-1.1, EUPL-1.2, CECILL-2.1, OSL-3.0, SSPL-1.0.
- Recognition of SPDX -only / -or-later suffixes and the legacy + operator for the GNU family (e.g. GPL-3.0-only, AGPL-3.0-or-later, LGPL-2.1+), all mapping to the correct copyleft category.
- Cleaned up the alias table to use fully-normalized keys


## [1.0.12] - 2026-06-08

### Fixed

- Add cc0 license compatibility


## [1.0.11] - 2025-11-17

### Fixed

- Fix normalisation of aliased license names


## [1.0.10] - 2025-11-17

### Changed

- Warnings take ignored packages into account

### Fixed

- Added BSD Zero Clause and variations


## [1.0.9] - 2025-11-03

### Fixed

- Add license aliases to catch alternative spellings


## [1.0.8] - 2025-10-31

### Fixed

- Hide list of valid dependencies by default
- Add --verbose flag to show valid dependencies


## [1.0.7] - 2025-10-29

### Fixed

- Aggressively normalises license names to catch variations


## [1.0.6] - 2025-10-29

### Added

- Accounts for proprietary software with 'All Rights Reserved' license

### Changed

- Missing license is now treated as proprietary, with a warning displayed


## [1.0.5] - 2025-10-29

### Changed

- Replace custom version task with versionise package


## [1.0.4] - 2025-10-28

### Fixed

- Fix release creation"



## [1.0.3] - 2025-10-28

### Added

- Create git release via version script

### Fixed

- Remove publishing



## [1.0.2] - 2025-10-28

### Fixed

- Fix publishing



## [1.0.1] - 2025-10-28

### Fixed

- Fix prompting when publishing inside script



## [1.0.0] - 2025-10-28

### Added

- Mix task to check license compatibility
- Easy-to-use versioning script



## [0.1.0] - 2025-01-XX

### Added
- Initial release of Depscheck
- License detection from local `hex_metadata.config` files
- Built-in license compatibility rules for common open source licenses
- Support for permissive licenses (MIT, Apache-2.0, BSD, ISC)
- Support for weak copyleft licenses (LGPL, MPL, EPL, CDDL)
- Support for strong copyleft licenses (GPL, AGPL)
- Configuration file support (`.depscheck.exs`)
- Package ignore list functionality
- Mix task CLI (`mix depscheck`)
- Colored terminal output
- CI/CD integration with proper exit codes
- Comprehensive test suite (69 tests)
- Full documentation including license compatibility rules
- GitHub Actions workflow example

### Features
- Zero runtime dependencies (only dev dependencies)
- Works completely offline
- Fast execution (< 1 second for typical projects)
- Pattern matching-based compatibility engine
- Detailed error messages with actionable feedback

[0.1.0]: https://github.com/dylanblakemore/depscheck/releases/tag/v0.1.0

