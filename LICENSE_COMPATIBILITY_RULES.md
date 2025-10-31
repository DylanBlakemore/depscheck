# License Compatibility Rules

> **⚠️ IMPORTANT DISCLAIMER**
>
> **This tool and documentation are NOT legal advice.** Depscheck is a guideline and early warning system to help identify potential license compatibility issues in your project dependencies. The rules and recommendations provided here are:
>
> - **Educational and informational** - Intended to help you understand common license compatibility patterns
> - **Simplified guidelines** - Real-world license compatibility can be complex and context-dependent
> - **Not a substitute for legal counsel** - When in doubt about license compatibility, especially for commercial projects, consult with a qualified attorney who specializes in software licensing law
> - **May not cover all edge cases** - License interpretations can vary, and there may be exceptions or nuances not captured here
>
> Use this tool as a helpful starting point, but do not rely on it as definitive legal guidance. The authors and contributors of Depscheck are not responsible for any legal issues that may arise from using this tool or following these guidelines.

---

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

### 4. Proprietary Licenses
**Examples:** All Rights Reserved, Unlicensed, Proprietary

**What they mean:**
- "This code is not licensed for others to use"
- All rights reserved by the author
- No permission to use, copy, modify, or distribute
- Cannot be used in any other project without explicit permission
- Default state when no license is declared

**Think of them as:** "This code belongs to me and you can't use it"

---

## Compatibility Rules

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
- Proprietary/closed-source project using LGPL dependency

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

### Rule 4: Proprietary Dependencies
**Proprietary license dependencies are ONLY compatible with:**
- ✅ Other proprietary projects (All Rights Reserved, Unlicensed, etc.)
- ❌ Permissive projects (MIT, Apache, BSD)
- ❌ Weak copyleft projects (LGPL, MPL)
- ❌ Strong copyleft projects (GPL)

✅ **Examples that work:**
- Proprietary project using proprietary dependency
- All Rights Reserved project using Unlicensed dependency

❌ **Examples that DON'T work:**
- MIT project using proprietary dependency ⚠️ **No legal right to use**
- Apache project using unlicensed dependency ⚠️ **No legal right to use**

**Why:** Proprietary code has no license, meaning you have no legal right to use it. This applies to both your project and your dependencies.

---

### Rule 5: Unlicensed Dependencies
**Unlicensed dependencies (unknown licenses) are treated as:**
- ⚠️ **Warnings only** for open source projects (MIT, Apache, GPL, etc.)
- ❌ **Blocked** for proprietary projects (no legal right to use)

**Why:** Unknown licenses are risky - you don't know what permissions you have. For proprietary projects, this is especially dangerous since you have no legal right to use unlicensed code.

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
- ✅ Proprietary dependencies (All Rights Reserved, Unlicensed, etc.)
- ❌ LGPL dependencies ⚠️ **This will fail the check**
- ❌ MPL dependencies ⚠️ **This will fail the check**
- ❌ GPL dependencies ⚠️ **This will fail the check**
- ❌ AGPL dependencies ⚠️ **This will fail the check**
- ❌ Unlicensed dependencies ⚠️ **This will fail the check**

**Important:** Depscheck will warn you: "Project has no license - treating as proprietary (all rights reserved)"

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

## Future Enhancements

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
| **Proprietary**     | ✅ Yes              | ❌ No                   | ❌ No                    |

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

**Important Reminder:** The compatibility rules and guidelines in this document are simplified and provided for educational purposes only. They are not legal advice. License compatibility can be complex, and the applicability of these rules may vary based on:

- Your specific use case and context
- Jurisdiction and local laws
- The exact wording of license agreements
- Court interpretations and legal precedent
- Your organization's policies and requirements

**When in doubt, especially for commercial projects or complex scenarios, consult with a qualified attorney who specializes in software licensing law.** Depscheck is an early warning system, not a legal guarantee.

