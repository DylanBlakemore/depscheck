# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

