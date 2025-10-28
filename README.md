# Depscheck

A CI/CD tool for checking dependency license compatibility in Elixir projects.

Depscheck helps ensure your project's dependencies have compatible licenses by reading license information from local `hex_metadata.config` files and checking them against your project's license.

## Features

- ✅ **Offline Operation** - No API calls needed, reads from local hex metadata files
- ✅ **Fast** - Completes in under a second for most projects
- ✅ **Smart** - Built-in license compatibility rules based on industry standards
- ✅ **Simple** - Zero configuration needed for basic usage
- ✅ **CI/CD Ready** - Exit codes and clear output for pipeline integration

## Installation

Add `depscheck` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:depscheck, "~> 0.1.0", only: [:dev, :test], runtime: false}
  ]
end
```

## Usage

### Basic Usage

Run the Mix task:

```bash
mix depscheck
```

Example output:

```
Checking licenses for MyProject (MIT)...

✓ jason (Apache-2.0) - Compatible
✓ plug (Apache-2.0) - Compatible
✓ phoenix (MIT) - Compatible
✗ some_gpl_package (GPL-3.0) - INCOMPATIBLE

Found 1 license violation(s)

Violations:
  • some_gpl_package (GPL-3.0): Strong copyleft license GPL-3.0 cannot be used in permissive project
```

### Configuration

Create a `.depscheck.exs` file in your project root to ignore specific packages:

```elixir
%{
  ignored_packages: ["some_package", "another_package"]
}
```

### CI/CD Integration

Depscheck exits with code `0` on success and `1` on failure, making it perfect for CI/CD pipelines. When violations are found, the command will fail and stop your CI pipeline.

#### GitHub Actions

Use the provided workflow file (`.github/workflows/license_check.yml`):

```yaml
name: License Check

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  check-licenses:
    name: Check Dependency Licenses
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up Elixir
        uses: erlef/setup-beam@v1
        with:
          elixir-version: '1.18.0'
          otp-version: '27.0'
      
      - name: Restore dependencies cache
        uses: actions/cache@v4
        with:
          path: deps
          key: ${{ runner.os }}-mix-${{ hashFiles('**/mix.lock') }}
          restore-keys: ${{ runner.os }}-mix-
      
      - name: Install dependencies
        run: mix deps.get
      
      - name: Check dependency licenses
        run: mix depscheck
```

Or add it to an existing workflow:

```yaml
- name: Check dependency licenses
  run: mix depscheck
```

#### GitLab CI

```yaml
license_check:
  stage: test
  script:
    - mix deps.get
    - mix depscheck
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
    - if: '$CI_COMMIT_BRANCH == "main"'
```

#### CircleCI

```yaml
- run:
    name: Check dependency licenses
    command: |
      mix deps.get
      mix depscheck
```

#### Exit Codes

- `0` - All dependencies are compatible (CI passes ✅)
- `1` - License violations found (CI fails ❌)

## How It Works

1. **Reads your project license** from `mix.exs`
2. **Reads dependency licenses** from `deps/*/hex_metadata.config` files (downloaded by `mix deps.get`)
3. **Checks compatibility** using built-in license compatibility rules
4. **Reports violations** with clear, actionable messages

## License Compatibility

Depscheck implements industry-standard license compatibility rules:

- **Permissive licenses** (MIT, Apache-2.0, BSD) are compatible with everything
- **Weak copyleft licenses** (LGPL, MPL) are compatible with most open source projects
- **Strong copyleft licenses** (GPL, AGPL) require your entire project to be compatible

For detailed information about license compatibility rules, see [LICENSE_COMPATIBILITY_RULES.md](LICENSE_COMPATIBILITY_RULES.md).

## API Usage

You can also use Depscheck programmatically:

```elixir
# Check all dependencies
result = Depscheck.check()

# Get project license
license = Depscheck.project_license()

# Get all dependencies
deps = Depscheck.dependencies()
```

## Supported Licenses

### Permissive
- MIT
- Apache-2.0
- BSD-2-Clause, BSD-3-Clause
- ISC
- Unlicense

### Weak Copyleft
- LGPL-2.1, LGPL-3.0
- MPL-2.0
- EPL-2.0
- CDDL-1.0

### Strong Copyleft
- GPL-2.0, GPL-3.0
- AGPL-3.0

Unknown licenses are treated as compatible (warning only).

## Development

### Running Tests

```bash
mix test
```

### Running Quality Checks

```bash
mix precommit  # Runs format, test, credo, and dialyzer
```

## Inspiration

This project was inspired by [hex_licenses](https://github.com/ericmj/hex_licenses) by Eric Meadows-Jönsson. The approach of reading license information from local `hex_metadata.config` files (rather than making API calls) was adapted from that project. Thank you to Eric and the Hex team for making this pattern available!

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Roadmap

Future enhancements may include:

- Support for dual-licensed packages
- Alternative package suggestions
- More nuanced compatibility rules
- JSON output format
- GitHub Actions annotations
- Support for git/path dependencies

## Links

- [License Compatibility Rules](LICENSE_COMPATIBILITY_RULES.md) - Detailed explanation of compatibility logic
- [hex_licenses](https://github.com/ericmj/hex_licenses) - Inspiration for this project
