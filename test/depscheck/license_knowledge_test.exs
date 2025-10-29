defmodule Depscheck.LicenseKnowledgeTest do
  use ExUnit.Case, async: true
  doctest Depscheck.LicenseKnowledge

  alias Depscheck.LicenseKnowledge

  describe "get_category/1" do
    test "returns :permissive for MIT" do
      assert LicenseKnowledge.get_category("MIT") == :permissive
    end

    test "returns :permissive for Apache-2.0" do
      assert LicenseKnowledge.get_category("Apache-2.0") == :permissive
    end

    test "returns :permissive for BSD licenses" do
      assert LicenseKnowledge.get_category("BSD-2-Clause") == :permissive
      assert LicenseKnowledge.get_category("BSD-3-Clause") == :permissive
    end

    test "returns :permissive for ISC" do
      assert LicenseKnowledge.get_category("ISC") == :permissive
    end

    test "returns :weak_copyleft for LGPL" do
      assert LicenseKnowledge.get_category("LGPL-2.1") == :weak_copyleft
      assert LicenseKnowledge.get_category("LGPL-3.0") == :weak_copyleft
    end

    test "returns :weak_copyleft for MPL-2.0" do
      assert LicenseKnowledge.get_category("MPL-2.0") == :weak_copyleft
    end

    test "returns :strong_copyleft for GPL" do
      assert LicenseKnowledge.get_category("GPL-2.0") == :strong_copyleft
      assert LicenseKnowledge.get_category("GPL-3.0") == :strong_copyleft
    end

    test "returns :strong_copyleft for AGPL" do
      assert LicenseKnowledge.get_category("AGPL-3.0") == :strong_copyleft
    end

    test "returns :proprietary for proprietary licenses" do
      assert LicenseKnowledge.get_category("All Rights Reserved") == :proprietary
      assert LicenseKnowledge.get_category("Unlicensed") == :proprietary
      assert LicenseKnowledge.get_category("Proprietary") == :proprietary
    end

    test "returns :unknown for unrecognized licenses" do
      assert LicenseKnowledge.get_category("Unknown-License") == :unknown
      assert LicenseKnowledge.get_category("Custom-License") == :unknown
    end

    test "handles case insensitive license names" do
      assert LicenseKnowledge.get_category("mit") == :permissive
      assert LicenseKnowledge.get_category("MIT") == :permissive
      assert LicenseKnowledge.get_category("MiT") == :permissive
    end

    test "handles whitespace in license names" do
      assert LicenseKnowledge.get_category(" MIT ") == :permissive
      assert LicenseKnowledge.get_category("  GPL-3.0  ") == :strong_copyleft
    end

    test "normalizes license name variations" do
      # Space variations
      assert LicenseKnowledge.get_category("Apache 2.0") == :permissive
      assert LicenseKnowledge.get_category("BSD 2 Clause") == :permissive
      assert LicenseKnowledge.get_category("BSD 3 Clause") == :permissive
      assert LicenseKnowledge.get_category("BSD 4 Clause") == :permissive
      assert LicenseKnowledge.get_category("GPL 2.0") == :strong_copyleft
      assert LicenseKnowledge.get_category("GPL 3.0") == :strong_copyleft
      assert LicenseKnowledge.get_category("LGPL 2.1") == :weak_copyleft
      assert LicenseKnowledge.get_category("LGPL 3.0") == :weak_copyleft

      # License suffix variations
      assert LicenseKnowledge.get_category("MIT License") == :permissive
      assert LicenseKnowledge.get_category("MIT license") == :permissive

      # Mixed spacing and dashes
      assert LicenseKnowledge.get_category("Apache-2.0") == :permissive
      assert LicenseKnowledge.get_category("BSD-2-Clause") == :permissive
      assert LicenseKnowledge.get_category("BSD-3-Clause") == :permissive
      assert LicenseKnowledge.get_category("BSD-4-Clause") == :permissive
    end

    test "handles real-world license variations from dependency metadata" do
      # These are the exact variations you encountered
      # Should map to BSD-3-Clause
      assert LicenseKnowledge.get_category("BSD") == :permissive
      assert LicenseKnowledge.get_category("Apache 2.0") == :permissive
      assert LicenseKnowledge.get_category("BSD 2-Clause") == :permissive
      assert LicenseKnowledge.get_category("BSD-4-Clause") == :permissive

      # Additional edge cases
      assert LicenseKnowledge.get_category("Apache-2.0") == :permissive
      assert LicenseKnowledge.get_category("BSD-2-Clause") == :permissive
      assert LicenseKnowledge.get_category("BSD-3-Clause") == :permissive
      assert LicenseKnowledge.get_category("MIT") == :permissive
      assert LicenseKnowledge.get_category("MIT License") == :permissive
      assert LicenseKnowledge.get_category("GPL-2.0") == :strong_copyleft
      assert LicenseKnowledge.get_category("GPL 3.0") == :strong_copyleft
      assert LicenseKnowledge.get_category("LGPL-2.1") == :weak_copyleft
      assert LicenseKnowledge.get_category("LGPL 3.0") == :weak_copyleft
    end

    test "handles complex spacing and punctuation variations" do
      # Multiple spaces
      assert LicenseKnowledge.get_category("Apache  2.0") == :permissive
      assert LicenseKnowledge.get_category("BSD   2   Clause") == :permissive

      # Mixed dashes and spaces
      assert LicenseKnowledge.get_category("Apache- 2.0") == :permissive
      assert LicenseKnowledge.get_category("BSD -2- Clause") == :permissive

      # Extra dashes
      assert LicenseKnowledge.get_category("Apache--2.0") == :permissive
      assert LicenseKnowledge.get_category("BSD---2---Clause") == :permissive

      # Leading/trailing punctuation
      assert LicenseKnowledge.get_category("-Apache-2.0-") == :permissive
      assert LicenseKnowledge.get_category("  BSD 2 Clause  ") == :permissive
    end
  end

  describe "permissive?/1" do
    test "returns true for permissive licenses" do
      assert LicenseKnowledge.permissive?("MIT")
      assert LicenseKnowledge.permissive?("Apache-2.0")
      assert LicenseKnowledge.permissive?("BSD-3-Clause")
    end

    test "returns false for copyleft licenses" do
      refute LicenseKnowledge.permissive?("GPL-3.0")
      refute LicenseKnowledge.permissive?("LGPL-3.0")
    end

    test "returns false for unknown licenses" do
      refute LicenseKnowledge.permissive?("Unknown")
    end
  end

  describe "copyleft?/1" do
    test "returns true for weak copyleft licenses" do
      assert LicenseKnowledge.copyleft?("LGPL-3.0")
      assert LicenseKnowledge.copyleft?("MPL-2.0")
    end

    test "returns true for strong copyleft licenses" do
      assert LicenseKnowledge.copyleft?("GPL-3.0")
      assert LicenseKnowledge.copyleft?("AGPL-3.0")
    end

    test "returns false for permissive licenses" do
      refute LicenseKnowledge.copyleft?("MIT")
      refute LicenseKnowledge.copyleft?("Apache-2.0")
    end

    test "returns false for unknown licenses" do
      refute LicenseKnowledge.copyleft?("Unknown")
    end
  end

  describe "proprietary?/1" do
    test "returns true for proprietary licenses" do
      assert LicenseKnowledge.proprietary?("All Rights Reserved")
      assert LicenseKnowledge.proprietary?("Unlicensed")
      assert LicenseKnowledge.proprietary?("Proprietary")
    end

    test "returns false for permissive licenses" do
      refute LicenseKnowledge.proprietary?("MIT")
      refute LicenseKnowledge.proprietary?("Apache-2.0")
    end

    test "returns false for copyleft licenses" do
      refute LicenseKnowledge.proprietary?("GPL-3.0")
      refute LicenseKnowledge.proprietary?("LGPL-3.0")
    end

    test "returns false for unknown licenses" do
      refute LicenseKnowledge.proprietary?("Unknown")
    end
  end

  describe "list_licenses_by_category/1" do
    test "returns permissive licenses" do
      licenses = LicenseKnowledge.list_licenses_by_category(:permissive)
      assert "MIT" in licenses
      assert "Apache-2.0" in licenses
      assert length(licenses) == 7
    end

    test "returns weak copyleft licenses" do
      licenses = LicenseKnowledge.list_licenses_by_category(:weak_copyleft)
      assert "LGPL-3.0" in licenses
      assert "MPL-2.0" in licenses
      assert length(licenses) == 5
    end

    test "returns strong copyleft licenses" do
      licenses = LicenseKnowledge.list_licenses_by_category(:strong_copyleft)
      assert "GPL-3.0" in licenses
      assert "AGPL-3.0" in licenses
      assert length(licenses) == 3
    end

    test "returns proprietary licenses" do
      licenses = LicenseKnowledge.list_licenses_by_category(:proprietary)
      assert "All Rights Reserved" in licenses
      assert "Unlicensed" in licenses
      assert "Proprietary" in licenses
      assert length(licenses) == 3
    end

    test "returns empty list for unknown category" do
      assert LicenseKnowledge.list_licenses_by_category(:unknown) == []
    end
  end
end
