# Depscheck - Dependency License Checker

## Product Requirements Document (PRD)

### 1. Overview

**Product Name:** Depscheck  
**Version:** 0.1.0  
**Purpose:** A CI/CD pipeline tool for checking dependency licenses to ensure compliance with project licensing requirements.

### 2. Problem Statement

Modern software projects depend on numerous third-party packages, each with their own licensing terms. Without proper license checking, projects risk:
- Violating license terms of dependencies
- Inadvertently including incompatible licenses
- Legal compliance issues in commercial environments
- License conflicts that could prevent distribution

### 3. Goals & Objectives

#### Primary Goals
- Automate license compliance checking in CI/CD pipelines
- Prevent license violations before code reaches production
- Provide clear, actionable feedback on license issues
- Support flexible configuration for different project needs

#### Success Metrics
- Zero false positives in license detection
- < 5 second execution time for typical projects
- 100% compatibility with major CI/CD platforms
- Clear, actionable error messages

### 4. Target Users

- **Primary:** DevOps engineers and developers setting up CI/CD pipelines
- **Secondary:** Legal teams requiring license compliance reports
- **Tertiary:** Open source maintainers ensuring license compatibility

### 5. Core Features

#### 5.1 License Detection
- Parse `mix.exs` and `mix.lock` files
- Extract license information from Hex packages
- Support for multiple license formats (SPDX, custom)
- Detect license compatibility issues

#### 5.2 Intelligent License Analysis
- Automatic license compatibility detection
- Project license inference and validation
- Smart conflict resolution recommendations
- Package exclusion/allowlist functionality
- Built-in license compatibility knowledge base

#### 5.3 CI/CD Integration
- Exit codes for pipeline integration
- Configurable output formats (JSON, plain text)
- GitHub Actions, GitLab CI, Jenkins compatibility
- Configurable failure thresholds

#### 5.4 Reporting
- Detailed license reports
- Violation summaries
- Recommendations for resolution
- Export capabilities for legal review

### 6. User Stories

#### As a DevOps Engineer
- I want to add depscheck to my CI pipeline so that license violations are caught automatically
- I want the tool to automatically understand license compatibility without manual configuration
- I want to exclude certain packages from checking so that I can handle them separately

#### As a Developer
- I want clear error messages when license violations occur so that I know exactly what to fix
- I want the tool to automatically detect my project's license and validate compatibility
- I want to see a summary of all dependencies and their licenses so that I understand my project's license landscape
- I want smart recommendations for resolving license conflicts

#### As a Legal Team Member
- I want detailed reports on all dependencies and their licenses so that I can perform compliance reviews
- I want to export license information in standard formats so that I can integrate with existing legal workflows

### 7. Non-Goals (Future Considerations)

- Real-time license monitoring (v2+)
- License recommendation engine (v2+)
- Integration with package registries beyond Hex (v2+)
- GUI/web interface (v2+)

### 8. Technical Requirements

#### 8.1 Performance
- Must complete license checking in < 5 seconds for projects with < 100 dependencies
- Memory usage should not exceed 100MB for typical projects
- Should not require internet connectivity for cached license data

#### 8.2 Compatibility
- Elixir 1.18+
- OTP 24+
- Support for all major CI/CD platforms
- Compatible with Mix 1.18+

#### 8.3 Reliability
- 99.9% uptime for license data fetching
- Graceful handling of network failures
- Comprehensive error handling and logging

### 9. Configuration Schema

```elixir
# depscheck.exs
%{
  project: %{
    # Optional: Override auto-detected license
    license: "MIT",
    private: false,
    allow_private_deps: true
  },
  # Optional: Override automatic compatibility rules
  compatibility_rules: %{
    strict_mode: true,  # Fail on any compatibility issues
    allow_copyleft: false,  # Block GPL/AGPL licenses
    allow_weak_copyleft: true  # Allow LGPL, MPL, etc.
  },
  ignored_packages: ["some-package", "another-package"],
  output_format: :json, # :json, :text, :github
  fail_on_warnings: false
}
```

### 10. API Design

#### 10.1 Main Functions
```elixir
# Check dependencies and return results
Depscheck.check_dependencies(config \\ %{})

# Generate license report
Depscheck.generate_report(config \\ %{})

# Validate single package license
Depscheck.validate_package(package_name, license, config \\ %{})

# Get license compatibility information
Depscheck.get_compatibility_info(project_license, dependency_license)

# Auto-detect project license from mix.exs
Depscheck.detect_project_license()

# Get smart recommendations for license conflicts
Depscheck.get_recommendations(conflicts)
```

#### 10.2 CLI Interface
```bash
# Basic usage
mix depscheck

# With config file
mix depscheck --config depscheck.exs

# Generate report
mix depscheck --report --output licenses.json

# Check specific package
mix depscheck --package phoenix
```

### 11. Intelligent License Compatibility System

#### 11.1 License Knowledge Base
The package will include a comprehensive knowledge base of license compatibility rules:

**License Categories:**
- **Permissive**: MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC
- **Weak Copyleft**: LGPL-2.1, LGPL-3.0, MPL-2.0, EPL-2.0
- **Strong Copyleft**: GPL-2.0, GPL-3.0, AGPL-3.0
- **Proprietary**: Commercial, All Rights Reserved
- **Public Domain**: CC0, Unlicense

**Compatibility Rules:**
- Permissive licenses are compatible with all other licenses
- Weak copyleft licenses are compatible with permissive and other weak copyleft licenses
- Strong copyleft licenses require the entire project to be under compatible terms
- Proprietary licenses are generally incompatible with open source licenses

#### 11.2 Automatic License Detection
- Parse `mix.exs` to detect project license
- Infer license from project metadata and files
- Handle multiple license declarations
- Detect license changes and warn about implications

#### 11.3 Smart Conflict Resolution
- Provide specific recommendations for each conflict
- Suggest alternative packages with compatible licenses
- Explain the implications of different resolution strategies
- Offer configuration overrides for edge cases

#### 11.4 License Compatibility Matrix
```elixir
# Built-in compatibility rules
%{
  "MIT" => %{
    compatible_with: :all,
    can_use_in: [:permissive, :weak_copyleft, :strong_copyleft, :proprietary]
  },
  "GPL-3.0" => %{
    compatible_with: [:permissive, :weak_copyleft, :gpl_compatible],
    can_use_in: [:gpl_projects_only],
    requires: :copyleft_propagation
  },
  "Apache-2.0" => %{
    compatible_with: [:permissive, :weak_copyleft, :apache_compatible],
    can_use_in: [:permissive, :weak_copyleft, :apache_projects]
  }
}
```

### 12. Success Criteria

- [ ] Successfully detects license violations in test projects
- [ ] Automatically understands license compatibility without manual configuration
- [ ] Provides intelligent recommendations for resolving conflicts
- [ ] Integrates cleanly with GitHub Actions and GitLab CI
- [ ] Provides clear, actionable error messages
- [ ] Supports all major open source licenses
- [ ] Handles edge cases gracefully (missing licenses, malformed data)
- [ ] Performance meets requirements (< 5s for typical projects)

---

## Architectural Decisions & Technology Choices

### 1. Core Architecture

#### 1.1 Modular Design
**Decision:** Implement a modular architecture with separate concerns for license detection, validation, and reporting.

**Rationale:** 
- Enables easy testing of individual components
- Allows for future feature extensions
- Improves code maintainability
- Supports different output formats

**Implementation:**
```elixir
Depscheck/
├── LicenseDetector    # Extract license info from packages
├── LicenseValidator   # Check license compatibility
├── CompatibilityEngine # Intelligent license compatibility logic
├── KnowledgeBase      # Built-in license compatibility rules
├── ConflictResolver   # Smart conflict resolution and recommendations
├── ConfigManager      # Handle configuration
├── Reporter          # Generate reports and output
└── CLI               # Command-line interface
```

#### 1.2 Functional Programming Approach
**Decision:** Use Elixir's functional programming paradigm with pure functions where possible.

**Rationale:**
- Easier testing and debugging
- Better concurrency handling
- Immutable data structures prevent side effects
- Aligns with Elixir best practices

### 2. Technology Stack

#### 2.1 Core Language: Elixir
**Decision:** Use Elixir as the primary language.

**Rationale:**
- Excellent for CLI tools and system utilities
- Built-in concurrency for parallel license checking
- Strong pattern matching for license parsing
- Excellent testing framework (ExUnit)
- Easy deployment and distribution

#### 2.2 Package Management: Mix
**Decision:** Use Mix for dependency management and project structure.

**Rationale:**
- Native Elixir tooling
- Excellent for library development
- Built-in testing and documentation generation
- Easy publishing to Hex

#### 2.3 Configuration: Native Elixir
**Decision:** Use native Elixir configuration files instead of YAML/JSON.

**Rationale:**
- Type safety and compile-time checking
- Better IDE support
- Easier to validate configuration
- Consistent with Elixir ecosystem

### 3. Data Management

#### 3.1 License Data Storage
**Decision:** Use in-memory caching with optional persistent storage, plus embedded knowledge base.

**Rationale:**
- Fast access for repeated checks
- Reduces API calls to Hex
- Can work offline with cached data
- Built-in license knowledge eliminates external dependencies
- Simple implementation

**Implementation:**
```elixir
# In-memory ETS table for license cache
:ets.new(:license_cache, [:set, :public, :named_table])

# Optional persistent cache using DETS
:dets.open_file(:license_cache, [{:file, "license_cache.dets"}])

# Embedded license compatibility knowledge base
@license_knowledge_base %{
  "MIT" => %{category: :permissive, compatible_with: :all},
  "GPL-3.0" => %{category: :strong_copyleft, requires: :copyleft_propagation},
  # ... more licenses
}
```

#### 3.2 Configuration Management
**Decision:** Use a structured configuration system with validation.

**Rationale:**
- Prevents configuration errors
- Provides clear error messages
- Supports different environments
- Easy to extend

### 4. Intelligent License System Architecture

#### 4.1 License Knowledge Base
**Decision:** Embed a comprehensive license compatibility knowledge base directly in the package.

**Rationale:**
- No external API dependencies for license rules
- Works offline completely
- Fast access to compatibility information
- Easy to maintain and update
- Consistent behavior across environments

**Implementation:**
```elixir
defmodule Depscheck.KnowledgeBase do
  @license_categories %{
    permissive: ["MIT", "Apache-2.0", "BSD-2-Clause", "BSD-3-Clause", "ISC", "Unlicense"],
    weak_copyleft: ["LGPL-2.1", "LGPL-3.0", "MPL-2.0", "EPL-2.0", "CDDL-1.0"],
    strong_copyleft: ["GPL-2.0", "GPL-3.0", "AGPL-3.0"],
    proprietary: ["Commercial", "All Rights Reserved"]
  }
  
  @compatibility_rules %{
    permissive: %{compatible_with: :all, can_use_in: :all},
    weak_copyleft: %{compatible_with: [:permissive, :weak_copyleft], can_use_in: [:permissive, :weak_copyleft]},
    strong_copyleft: %{compatible_with: [:permissive, :weak_copyleft, :gpl_compatible], can_use_in: [:gpl_projects_only]},
    proprietary: %{compatible_with: [], can_use_in: [:proprietary_only]}
  }
end
```

#### 4.2 Compatibility Engine
**Decision:** Implement a rule-based compatibility engine with pattern matching.

**Rationale:**
- Leverages Elixir's pattern matching for clean, readable code
- Easy to test and debug
- Extensible for new license types
- Clear separation of concerns

**Implementation:**
```elixir
defmodule Depscheck.CompatibilityEngine do
  def check_compatibility(project_license, dependency_license) do
    project_category = get_license_category(project_license)
    dep_category = get_license_category(dependency_license)
    
    case {project_category, dep_category} do
      {_, :permissive} -> :compatible
      {:permissive, _} -> :compatible
      {:weak_copyleft, :weak_copyleft} -> :compatible
      {:strong_copyleft, _} -> :compatible
      _ -> {:incompatible, reason: "License compatibility conflict"}
    end
  end
end
```

#### 4.3 Conflict Resolution Engine
**Decision:** Implement intelligent conflict resolution with specific recommendations.

**Rationale:**
- Provides actionable guidance to developers
- Reduces time spent resolving license issues
- Educates developers about license implications
- Improves developer experience

**Implementation:**
```elixir
defmodule Depscheck.ConflictResolver do
  def resolve_conflict(project_license, dependency_license, package_name) do
    case get_conflict_type(project_license, dependency_license) do
      :copyleft_incompatibility ->
        %{
          type: :copyleft_incompatibility,
          message: "Package #{package_name} uses #{dependency_license} which is incompatible with your #{project_license} project",
          recommendations: [
            "Consider using an alternative package with a permissive license",
            "Change your project license to GPL-3.0 to be compatible",
            "Add #{package_name} to ignored_packages if you must use it"
          ],
          alternatives: find_alternatives(package_name, :permissive)
        }
    end
  end
end
```

### 5. External Dependencies

#### 5.1 HTTP Client: Mint
**Decision:** Use Mint for HTTP requests to Hex API.

**Rationale:**
- Lightweight and fast
- Good for simple API calls
- No external dependencies
- Excellent error handling

#### 5.2 JSON Parsing: Jason
**Decision:** Use Jason for JSON parsing.

**Rationale:**
- Fast and memory efficient
- Pure Elixir implementation
- Excellent error handling
- Widely used in Elixir community

#### 5.3 CLI: OptionParser
**Decision:** Use Elixir's built-in OptionParser for CLI functionality.

**Rationale:**
- No external dependencies
- Sufficient for current needs
- Easy to extend
- Consistent with Elixir tooling

### 5. Testing Strategy

#### 5.1 Unit Testing: ExUnit
**Decision:** Use ExUnit for all unit tests.

**Rationale:**
- Built into Elixir
- Excellent assertion library
- Good mocking capabilities
- Industry standard

#### 5.2 Integration Testing
**Decision:** Create test projects with known license configurations.

**Rationale:**
- Tests real-world scenarios
- Validates end-to-end functionality
- Easy to maintain
- Clear test data

#### 5.3 Property-Based Testing: StreamData
**Decision:** Use StreamData for property-based testing of license parsing.

**Rationale:**
- Finds edge cases automatically
- Validates parsing robustness
- Good for license format variations
- Catches regressions

### 6. Error Handling

#### 6.1 Error Types
**Decision:** Define custom error types for different failure modes.

**Rationale:**
- Clear error categorization
- Better user experience
- Easier debugging
- Consistent error handling

**Implementation:**
```elixir
defmodule Depscheck.Error do
  defexception [:message, :type, :package, :license]
  
  @type t :: %__MODULE__{
    message: String.t(),
    type: :license_violation | :network_error | :config_error,
    package: String.t() | nil,
    license: String.t() | nil
  }
end
```

#### 6.2 Graceful Degradation
**Decision:** Implement graceful degradation for network failures.

**Rationale:**
- Works offline with cached data
- Better user experience
- Reduces CI pipeline failures
- More robust tool

### 7. Performance Considerations

#### 7.1 Parallel Processing
**Decision:** Use Task.async_stream for parallel license checking.

**Rationale:**
- Leverages Elixir's concurrency
- Faster execution for multiple packages
- Non-blocking operations
- Easy to implement

#### 7.2 Caching Strategy
**Decision:** Implement multi-level caching (memory + disk).

**Rationale:**
- Fast access for repeated checks
- Reduces API calls
- Works offline
- Configurable cache size

### 8. Security Considerations

#### 8.1 Input Validation
**Decision:** Validate all inputs and configuration.

**Rationale:**
- Prevents injection attacks
- Ensures data integrity
- Better error messages
- Security best practice

#### 8.2 Network Security
**Decision:** Use HTTPS for all external API calls.

**Rationale:**
- Prevents man-in-the-middle attacks
- Ensures data integrity
- Industry standard
- Required for production use

### 9. Deployment & Distribution

#### 9.1 Hex Package
**Decision:** Publish as a Hex package.

**Rationale:**
- Easy installation via Mix
- Version management
- Dependency resolution
- Standard Elixir distribution

#### 9.2 CLI Installation
**Decision:** Support escript installation for global CLI access.

**Rationale:**
- Easy installation
- Global availability
- No Mix project required
- Better developer experience

### 10. Future Extensibility

#### 10.1 Plugin Architecture
**Decision:** Design for future plugin support.

**Rationale:**
- Easy to add new license sources
- Community contributions
- Flexible architecture
- Future-proof design

#### 10.2 API Design
**Decision:** Design clean, stable APIs.

**Rationale:**
- Easy to extend
- Backward compatibility
- Clear interfaces
- Good documentation

---

## Implementation Roadmap

### Phase 1: Core Functionality (v0.1.0)
- [ ] Basic license detection from mix.exs/mix.lock
- [ ] Embedded license knowledge base
- [ ] Intelligent compatibility engine
- [ ] Basic CLI interface
- [ ] Configuration system
- [ ] Unit tests

### Phase 2: Enhanced Features (v0.2.0)
- [ ] Hex API integration
- [ ] Caching system
- [ ] Conflict resolution engine with recommendations
- [ ] Multiple output formats
- [ ] CI/CD integration examples
- [ ] Integration tests

### Phase 3: Advanced Features (v0.3.0)
- [ ] Advanced reporting with smart recommendations
- [ ] Alternative package suggestions
- [ ] Performance optimizations
- [ ] Documentation and examples
- [ ] License change detection and warnings

### Phase 4: Ecosystem Integration (v0.4.0)
- [ ] GitHub Actions integration
- [ ] GitLab CI integration
- [ ] Plugin architecture for custom license rules
- [ ] Community contributions
- [ ] License trend analysis

---

This PRD and architectural document provides a comprehensive foundation for building the Depscheck package. The modular design and technology choices ensure the tool will be maintainable, extensible, and performant while meeting the core requirements for CI/CD license checking.
