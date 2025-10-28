# License Compatibility Rules

This document explains the license compatibility rules used by Depscheck in plain language.

## Overview

When you use a dependency in your project, that dependency's license must be **compatible** with your project's license. Some licenses allow you to do almost anything, while others have strict requirements about how you can use and distribute the code.

## The Basic Principle

**Your project license determines what dependency licenses you can use, not the other way around.**

Think of it like this: Your project's license is a promise you're making about how people can use your code. If you include a dependency with an incompatible license, you can't keep that promise.

---

## License Categories

Depscheck groups licenses into three main categories:

### 1. Permissive Licenses
**Examples:** MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC

**What they mean:**
- "Do whatever you want with this code"
- Very few restrictions
- You can use it in any type of project
- You can modify it, sell it, include it in proprietary software
- Usually just require you to keep the copyright notice

**Think of them as:** The most flexible licenses

---

### 2. Weak Copyleft Licenses
**Examples:** LGPL-2.1, LGPL-3.0, MPL-2.0

**What they mean:**
- "You can use this in your project, but if you modify THIS library, you must share those changes"
- You can use them in proprietary projects
- You can use them in open source projects
- If you modify the library itself, you must release those modifications
- Your own code can stay under your license

**Think of them as:** "Share improvements to me, but your code is yours"

---

### 3. Strong Copyleft Licenses
**Examples:** GPL-2.0, GPL-3.0, AGPL-3.0

**What they mean:**
- "If you use this code, your entire project must also be open source under a compatible license"
- Very restrictive
- Requires your whole project to be GPL-compatible
- Cannot be used in proprietary software
- Often called "viral" licenses because they spread to your code

**Think of them as:** "If you use me, you must be open source too"

---

## Compatibility Rules (MVP)

Here's what Depscheck checks:

### Rule 1: Permissive Dependencies
**Permissive license dependencies are ALWAYS compatible with any project license.**

✅ **Examples that work:**
- MIT project using MIT dependency
- MIT project using Apache-2.0 dependency
- GPL project using MIT dependency
- Proprietary project using BSD dependency

**Why:** Permissive licenses let you do anything, so they work everywhere.

---

### Rule 2: Weak Copyleft Dependencies
**Weak copyleft dependencies are compatible with:**
- ✅ Permissive projects (MIT, Apache, BSD, etc.)
- ✅ Other weak copyleft projects (LGPL, MPL)
- ✅ Strong copyleft projects (GPL)
- ❌ Proprietary projects (usually - there are exceptions but we're being conservative)

✅ **Examples that work:**
- MIT project using LGPL dependency
- LGPL project using MPL dependency
- GPL project using LGPL dependency

❌ **Examples that DON'T work:**
- Proprietary/closed-source project using LGPL dependency (flagged as incompatible in MVP)

**Why:** Weak copyleft licenses are designed to work with most open source licenses. They only require you to share changes to the library itself, not your whole project.

---

### Rule 3: Strong Copyleft Dependencies
**Strong copyleft dependencies are ONLY compatible with:**
- ✅ Other strong copyleft projects (GPL, AGPL)
- ❌ Permissive projects (MIT, Apache, BSD)
- ❌ Weak copyleft projects (LGPL, MPL)
- ❌ Proprietary projects

✅ **Examples that work:**
- GPL-3.0 project using GPL-2.0 dependency
- GPL project using AGPL dependency

❌ **Examples that DON'T work:**
- MIT project using GPL dependency ⚠️ **Most common violation**
- Apache project using GPL dependency
- BSD project using AGPL dependency
- Proprietary project using GPL dependency

**Why:** GPL requires your entire project to be GPL-compatible. If you're MIT licensed, you can't make that promise.

---

## Common Scenarios

### Scenario 1: MIT Project (Most Common)
**Your project:** MIT License

**You can use:**
- ✅ MIT dependencies
- ✅ Apache-2.0 dependencies
- ✅ BSD dependencies
- ✅ ISC dependencies
- ✅ LGPL dependencies
- ✅ MPL dependencies
- ❌ GPL dependencies ⚠️ **This will fail the check**
- ❌ AGPL dependencies ⚠️ **This will fail the check**

---

### Scenario 2: Apache-2.0 Project
**Your project:** Apache-2.0 License

**You can use:**
- ✅ MIT dependencies
- ✅ Apache-2.0 dependencies
- ✅ BSD dependencies
- ✅ ISC dependencies
- ✅ LGPL dependencies
- ✅ MPL dependencies
- ❌ GPL dependencies ⚠️ **This will fail the check**
- ❌ AGPL dependencies ⚠️ **This will fail the check**

---

### Scenario 3: GPL Project
**Your project:** GPL-3.0 License

**You can use:**
- ✅ MIT dependencies (permissive)
- ✅ Apache-2.0 dependencies (permissive)
- ✅ BSD dependencies (permissive)
- ✅ LGPL dependencies (weak copyleft)
- ✅ MPL dependencies (weak copyleft)
- ✅ GPL dependencies (same license)
- ✅ AGPL dependencies (compatible copyleft)

**Note:** GPL projects can use almost anything because GPL is the most restrictive - everything is compatible "upward" toward GPL.

---

### Scenario 4: Proprietary/Closed Source Project
**Your project:** No open source license (proprietary)

**You can use:**
- ✅ MIT dependencies
- ✅ Apache-2.0 dependencies
- ✅ BSD dependencies
- ✅ ISC dependencies
- ❌ LGPL dependencies ⚠️ **(MVP flags as incompatible - future versions may allow with caveats)**
- ❌ MPL dependencies ⚠️ **(MVP flags as incompatible)**
- ❌ GPL dependencies ⚠️ **This will fail the check**
- ❌ AGPL dependencies ⚠️ **This will fail the check**

---

## Special Cases

### Unknown Licenses
If a dependency has no license or an unrecognized license:
- ⚠️ Depscheck will **warn** but **not fail** (in MVP)
- You should investigate manually
- Unlicensed code is technically "all rights reserved"

### Multiple Licenses (Dual Licensed)
If a dependency offers multiple licenses (e.g., "MIT OR Apache-2.0"):
- Future versions will handle this intelligently
- MVP will see both licenses and may need manual review

### No Project License
If your project doesn't declare a license:
- Depscheck will warn you
- It will still check dependencies but can't determine compatibility
- You should add a license to your `mix.exs`

---

## Why These Rules?

### Legal Safety
These rules help you avoid:
- License violations that could lead to legal issues
- Accidentally making your proprietary code open source
- Distribution problems with your software

### Common Pitfall
**The #1 mistake:** Adding a GPL dependency to an MIT project.

This is incompatible because:
1. MIT says "anyone can use this code for anything"
2. GPL says "anyone who uses this must make their code GPL too"
3. You can't promise both things at once

---

## What Depscheck Does

When you run `mix depscheck`:

1. **Reads your project license** from `mix.exs`
2. **Reads all dependency licenses** from `deps/*/hex_metadata.config`
3. **Applies these compatibility rules** to each dependency
4. **Reports violations** if any dependency is incompatible
5. **Exits with code 1** if violations found (fails CI/CD)
6. **Exits with code 0** if everything is compatible (passes CI/CD)

---

## Ignoring Packages

Sometimes you need to ignore a package (e.g., you have special permission, or it's a dev-only tool):

Create `.depscheck.exs` in your project root:
```elixir
%{
  ignored_packages: ["some_package"]
}
```

Ignored packages will be skipped during compatibility checking.

---

## Future Enhancements (Not in MVP)

Future versions may include:
- Smarter handling of dual-licensed packages
- More nuanced rules for LGPL in proprietary projects
- Compatibility between specific GPL versions
- Recommendations for alternative packages
- Detailed explanations of why something is incompatible

---

## Quick Reference Table

| Your Project License | Can Use Permissive? | Can Use Weak Copyleft? | Can Use Strong Copyleft? |
|---------------------|--------------------|-----------------------|-------------------------|
| **MIT**             | ✅ Yes              | ✅ Yes                 | ❌ No                    |
| **Apache-2.0**      | ✅ Yes              | ✅ Yes                 | ❌ No                    |
| **BSD**             | ✅ Yes              | ✅ Yes                 | ❌ No                    |
| **LGPL**            | ✅ Yes              | ✅ Yes                 | ❌ No                    |
| **MPL**             | ✅ Yes              | ✅ Yes                 | ❌ No                    |
| **GPL**             | ✅ Yes              | ✅ Yes                 | ✅ Yes                   |
| **AGPL**            | ✅ Yes              | ✅ Yes                 | ✅ Yes                   |
| **Proprietary**     | ✅ Yes              | ❌ No (MVP)            | ❌ No                    |

---

## Summary

**The Golden Rule:** Permissive dependencies work everywhere. Copyleft dependencies have restrictions.

**The Common Case:** Most Elixir projects are MIT or Apache-2.0, and most dependencies are also MIT or Apache-2.0, so most projects will pass without issues.

**The Red Flag:** If you're building an MIT/Apache project and you see a GPL dependency, that's a problem you need to fix.

---

## Questions?

If Depscheck flags a violation and you're not sure why:

1. Check which category your project license is in
2. Check which category the dependency license is in
3. Look up the rule for that combination above
4. Consider if you really need that dependency
5. Look for an alternative with a compatible license
6. Or, if appropriate, consider changing your project's license

Remember: **This is legal advice territory.** When in doubt, consult with someone who understands software licensing law.

