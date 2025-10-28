# Release Checklist

This document outlines the steps to release a new version of Depscheck to Hex.pm.

## Pre-Release Checklist

- [ ] All tests pass (`mix test`)
- [ ] Code is formatted (`mix format`)
- [ ] Credo passes with no issues (`mix credo --strict`)
- [ ] Dialyzer passes with no warnings (`mix dialyzer`)
- [ ] Documentation is up to date
- [ ] CHANGELOG.md is updated with new version
- [ ] Version number is updated in:
  - [ ] `mix.exs` (project version)
  - [ ] `mix.exs` (docs source_ref)
  - [ ] `CHANGELOG.md` (release date)
- [ ] README.md examples are accurate
- [ ] LICENSE file is present and correct

## Release Steps

### 1. Bump Version (Automated)

Use the version task to automatically bump the version:

```bash
# For a patch release (0.1.0 -> 0.1.1)
mix version patch

# For a minor release (0.1.0 -> 0.2.0)
mix version minor

# For a major release (0.1.0 -> 1.0.0)
mix version major
```

This will:
- Update the version in `mix.exs`
- Update the `source_ref` in docs
- Add a new entry to `CHANGELOG.md`

### 2. Update CHANGELOG

Edit `CHANGELOG.md` and add release notes under the new version entry:

```markdown
## [0.1.1] - 2025-01-15

### Added
- New feature X

### Changed
- Improved Y

### Fixed
- Bug Z
```

### 3. Run Full Test Suite

```bash
MIX_ENV=test mix precommit
```

All checks must pass before releasing.

### 4. Build Documentation (Optional)

```bash
mix docs
```

Review the generated documentation in `doc/` directory.

### 5. Commit and Tag

```bash
git add .
git commit -m "Release v0.1.1"
git tag v0.1.1
git push origin main
git push origin v0.1.1
```

### 6. Publish to Hex

```bash
mix hex.publish
```

Review the package contents and confirm the publish.

### 7. Create GitHub Release

1. Go to https://github.com/dylanblakemore/depscheck/releases
2. Click "Create a new release"
3. Select tag `v0.1.0`
4. Title: "v0.1.0"
5. Copy release notes from CHANGELOG.md
6. Publish release

## Post-Release

- [ ] Verify package is available on https://hex.pm/packages/depscheck
- [ ] Test installation in a fresh project
- [ ] Announce release (optional)

## First Time Setup

If this is your first time publishing to Hex:

1. Create a Hex account at https://hex.pm/signup
2. Authenticate locally:
   ```bash
   mix hex.user auth
   ```

## Hex Package Configuration

The package is configured in `mix.exs`:

```elixir
defp package do
  [
    name: "depscheck",
    licenses: ["MIT"],
    links: %{
      "GitHub" => "https://github.com/dylanblakemore/depscheck",
      "Changelog" => "https://github.com/dylanblakemore/depscheck/blob/main/CHANGELOG.md"
    },
    files: ~w(lib .formatter.exs mix.exs README.md LICENSE CHANGELOG.md
              LICENSE_COMPATIBILITY_RULES.md .depscheck.exs.example)
  ]
end
```

## Troubleshooting

### Package validation fails

Run `mix hex.build` to see what files will be included and validate the package locally.

### Documentation doesn't generate

Ensure `ex_doc` is in your dependencies and run:
```bash
mix deps.get
mix docs
```

### Tests fail in CI but pass locally

Check that you're running tests in the correct environment:
```bash
MIX_ENV=test mix test
```

