# Depscheck - Minimum Viable Product (MVP) Implementation Plan

## Goal
Create the absolute minimum working version that provides value: **Check if any dependency has an incompatible license with your project.**

## What the MVP Does
1. Read project license from `mix.exs`
2. Read all dependency licenses from `deps/*/hex_metadata.config` files
3. Allow ignoring specific packages via simple config
4. Check if any dependency license is incompatible with project license
5. Print results and exit with appropriate code (0 = pass, 1 = fail)

## What the MVP Does NOT Do (Future Versions)
- ❌ Complex configuration options
- ❌ Multiple output formats (just simple text)
- ❌ Detailed recommendations
- ❌ Git/path dependencies
- ❌ Complex compatibility rules
- ❌ Caching (not needed - reads local files)

---

## Implementation Steps (6 Steps Total)

### Step 1: Create Basic Types (30 minutes)
**File:** `lib/depscheck/types.ex`

**What to create:**
```elixir
defmodule Depscheck.Types do
  @type license_category :: :permissive | :weak_copyleft | :strong_copyleft | :unknown
  
  @type dependency :: %{
    name: String.t(),
    licenses: [String.t()]
  }
  
  @type check_result :: %{
    status: :pass | :fail,
    project_license: String.t() | nil,
    dependencies: [dependency()],
    violations: [String.t()]
  }
  
  @type config :: %{
    ignored_packages: [String.t()]
  }
end
```

**Tests:** None needed (just type definitions)

---

### Step 2: Create License Knowledge Base (1 hour)
**File:** `lib/depscheck/license_knowledge.ex`

**What to implement:**
- Module attribute with license categories (just the most common ones)
- `get_category/1` - Returns category for a license name
- Handle case-insensitive matching
- Return `:unknown` for unrecognized licenses

**Licenses to include (keep it minimal):**
- Permissive: MIT, Apache-2.0, BSD-3-Clause, BSD-2-Clause, ISC
- Weak Copyleft: LGPL-2.1, LGPL-3.0, MPL-2.0
- Strong Copyleft: GPL-2.0, GPL-3.0, AGPL-3.0

**Tests:**
- Test known licenses return correct category
- Test case insensitivity
- Test unknown license returns `:unknown`

---

### Step 3: Create License Detector (2 hours)
**File:** `lib/depscheck/license_detector.ex`

**What to implement:**
- `get_project_license/0` - Read from mix.exs
  - Use `Mix.Project.config()[:licenses]` or `Mix.Project.config()[:license]`
  - Return first license if multiple
  - Return `nil` if not found
  
- `get_all_dependency_licenses/0` - Read from hex_metadata.config files
  - Get deps path with `Mix.Project.deps_path()`
  - List all directories in deps/
  - For each directory, read `hex_metadata.config`
  - Use `:file.consult/1` to read the file
  - Extract licenses with `List.keyfind(metadata, "licenses", 0)`
  - Return list of `%{name: name, licenses: licenses}`
  - Skip if file doesn't exist (git/path deps)

**Tests:**
- Test reading actual hex_metadata.config from deps/ (use real deps like credo)
- Test handling missing files
- Test malformed files

---

### Step 4: Create Simple Config Loader (30 minutes)
**File:** `lib/depscheck/config.ex`

**What to implement:**
- `load/0` - Load config from `.depscheck.exs` file in project root
  - Return default config if file doesn't exist
  - Use `Code.eval_file/1` to read config
  - Validate it's a map with `:ignored_packages` key
  - Return `{:ok, config}` or `{:error, reason}`

- Default config:
  ```elixir
  %{ignored_packages: []}
  ```

**Config file format:**
```elixir
# .depscheck.exs
%{
  ignored_packages: ["some_package", "another_package"]
}
```

**Tests:**
- Test loading valid config
- Test missing config file returns defaults
- Test invalid config returns error

---

### Step 5: Create Simple Compatibility Checker (1 hour)
**File:** `lib/depscheck/compatibility.ex`

**What to implement:**
- `check_compatibility/2` - Takes project license and dependency license
  - Get categories for both
  - Simple rules:
    - Permissive deps: always compatible
    - Weak copyleft deps: compatible with permissive and weak copyleft projects
    - Strong copyleft deps: only compatible with strong copyleft projects
    - Unknown: warn but don't fail
  - Return `:compatible` or `{:incompatible, reason}`

- `check_all/3` - Takes project license, list of dependencies, and config
  - Filter out ignored packages from config
  - Check each remaining dependency
  - Collect violations
  - Return check_result map

**Tests:**
- Test all compatibility combinations
- Test with unknown licenses
- Test with multiple dependencies
- Test ignored packages are filtered out

---

### Step 6: Create Mix Task (1 hour)
**File:** `lib/mix/tasks/depscheck.ex`

**What to implement:**
- Basic Mix.Task behavior
- `run/1` function:
  1. Load config
  2. Get project license
  3. Get all dependency licenses
  4. Check compatibility (with ignored packages)
  5. Print results (simple text output)
  6. Exit with code 0 (pass) or 1 (fail)

**Output format (keep it simple):**
```
Checking licenses for MyProject (MIT)...

✓ jason (Apache-2.0) - Compatible
✓ credo (MIT) - Compatible
⊘ some_package (MIT) - Ignored
✗ some_gpl_package (GPL-3.0) - INCOMPATIBLE

Found 1 license violation(s)
```

**Tests:**
- Test task execution
- Test exit codes
- Test output (capture IO)

---

### Step 7: Update Main Module (30 minutes)
**File:** `lib/depscheck.ex`

**What to implement:**
- Clean up placeholder code
- Add module documentation
- Expose main API function:
  - `check/0` - Run the check and return results

**Tests:**
- Basic integration test

---

## Total Estimated Time: 6.5 hours

## Success Criteria for MVP
- [ ] Can detect project license from mix.exs
- [ ] Can read licenses from deps/*/hex_metadata.config
- [ ] Can load config from `.depscheck.exs`
- [ ] Can ignore specified packages
- [ ] Can identify GPL dependencies in MIT projects (basic incompatibility)
- [ ] `mix depscheck` command works
- [ ] Exit code 0 for pass, 1 for violations
- [ ] All tests pass
- [ ] `mix precommit` passes (format, test, credo, dialyzer)

## What Gets Tested
- Use the depscheck project itself as test subject
- It has credo, dialyxir as deps (both MIT/Apache-2.0)
- Should pass with no violations

## Files to Create (8 files total)
1. `lib/depscheck/types.ex`
2. `lib/depscheck/license_knowledge.ex`
3. `lib/depscheck/license_detector.ex`
4. `lib/depscheck/config.ex`
5. `lib/depscheck/compatibility.ex`
6. `lib/mix/tasks/depscheck.ex`
7. Update `lib/depscheck.ex`
8. Tests for each module

## Dependencies Needed
**None!** Everything uses built-in Elixir/OTP functionality.

Keep existing dev dependencies:
- credo (already in mix.exs)
- dialyxir (already in mix.exs)

---

## Implementation Order
1. Types (foundation)
2. License Knowledge (no dependencies)
3. License Detector (uses Types)
4. Config (uses Types)
5. Compatibility (uses Types + Knowledge + Detector + Config)
6. Mix Task (uses everything)
7. Update main module (uses everything)

## Key Principles
- **No premature optimization** - Get it working first
- **Minimal configuration** - Just ignored packages, sensible defaults
- **No caching** - Not needed, files are local
- **Simple text output** - JSON can wait
- **Focus on common case** - MIT/Apache projects with permissive deps
- **Pattern matching over conditionals** - Use Elixir idiomatically
- **Small functions** - Each does one thing
- **Test with real data** - Use actual hex_metadata.config files from deps/

