defmodule Depscheck.CompatibilityTest do
  use ExUnit.Case, async: true
  doctest Depscheck.Compatibility

  alias Depscheck.Compatibility

  describe "check_compatibility/2" do
    test "permissive dependencies are always compatible" do
      assert Compatibility.check_compatibility("MIT", "Apache-2.0") == :compatible
      assert Compatibility.check_compatibility("GPL-3.0", "MIT") == :compatible
      assert Compatibility.check_compatibility("LGPL-3.0", "BSD-3-Clause") == :compatible
    end

    test "MIT project can use weak copyleft dependencies" do
      assert Compatibility.check_compatibility("MIT", "LGPL-3.0") == :compatible
      assert Compatibility.check_compatibility("MIT", "MPL-2.0") == :compatible
    end

    test "MIT project cannot use strong copyleft dependencies" do
      assert {:incompatible, reason} = Compatibility.check_compatibility("MIT", "GPL-3.0")
      assert reason =~ "GPL-3.0"
      assert reason =~ "permissive"
    end

    test "Apache project cannot use GPL dependencies" do
      assert {:incompatible, _reason} = Compatibility.check_compatibility("Apache-2.0", "GPL-3.0")

      assert {:incompatible, _reason} =
               Compatibility.check_compatibility("Apache-2.0", "AGPL-3.0")
    end

    test "GPL project can use permissive dependencies" do
      assert Compatibility.check_compatibility("GPL-3.0", "MIT") == :compatible
      assert Compatibility.check_compatibility("GPL-3.0", "Apache-2.0") == :compatible
    end

    test "GPL project can use weak copyleft dependencies" do
      assert Compatibility.check_compatibility("GPL-3.0", "LGPL-3.0") == :compatible
      assert Compatibility.check_compatibility("GPL-3.0", "MPL-2.0") == :compatible
    end

    test "GPL project can use other GPL dependencies" do
      assert Compatibility.check_compatibility("GPL-3.0", "GPL-2.0") == :compatible
      assert Compatibility.check_compatibility("GPL-3.0", "AGPL-3.0") == :compatible
    end

    test "LGPL project can use permissive and weak copyleft" do
      assert Compatibility.check_compatibility("LGPL-3.0", "MIT") == :compatible
      assert Compatibility.check_compatibility("LGPL-3.0", "MPL-2.0") == :compatible
    end

    test "LGPL project cannot use GPL" do
      assert {:incompatible, _reason} = Compatibility.check_compatibility("LGPL-3.0", "GPL-3.0")
    end

    test "unknown licenses are treated as compatible" do
      assert Compatibility.check_compatibility("MIT", "Unknown-License") == :compatible
      assert Compatibility.check_compatibility("Unknown-License", "MIT") == :compatible
    end

    test "nil project license is treated as compatible" do
      assert Compatibility.check_compatibility(nil, "MIT") == :compatible
      assert Compatibility.check_compatibility(nil, "GPL-3.0") == :compatible
    end

    test "proprietary project can use permissive dependencies" do
      assert Compatibility.check_compatibility("All Rights Reserved", "MIT") == :compatible
      assert Compatibility.check_compatibility("All Rights Reserved", "Apache-2.0") == :compatible

      assert Compatibility.check_compatibility("All Rights Reserved", "BSD-3-Clause") ==
               :compatible
    end

    test "proprietary project cannot use weak copyleft dependencies" do
      assert {:incompatible, reason} =
               Compatibility.check_compatibility("All Rights Reserved", "LGPL-3.0")

      assert reason =~ "proprietary project"
      assert reason =~ "LGPL-3.0"

      assert {:incompatible, reason} =
               Compatibility.check_compatibility("All Rights Reserved", "MPL-2.0")

      assert reason =~ "proprietary project"
    end

    test "proprietary project cannot use strong copyleft dependencies" do
      assert {:incompatible, reason} =
               Compatibility.check_compatibility("All Rights Reserved", "GPL-3.0")

      assert reason =~ "proprietary project"
      assert reason =~ "GPL-3.0"

      assert {:incompatible, reason} =
               Compatibility.check_compatibility("All Rights Reserved", "AGPL-3.0")

      assert reason =~ "proprietary project"
    end

    test "proprietary project can use other proprietary dependencies" do
      assert Compatibility.check_compatibility("All Rights Reserved", "Proprietary") ==
               :compatible

      assert Compatibility.check_compatibility("All Rights Reserved", "Unlicensed") == :compatible
    end

    test "proprietary project cannot use unlicensed dependencies" do
      assert {:incompatible, reason} =
               Compatibility.check_compatibility("All Rights Reserved", "Unknown-License")

      assert reason =~ "no legal right to use it"
    end
  end

  describe "check_all/3" do
    test "returns pass when all dependencies are compatible" do
      deps = [
        %{name: "jason", licenses: ["Apache-2.0"]},
        %{name: "plug", licenses: ["Apache-2.0"]}
      ]

      config = %{ignored_packages: [], project_license: nil}

      result = Compatibility.check_all("MIT", deps, config)

      assert result.status == :pass
      assert result.project_license == "MIT"
      assert Enum.empty?(result.violations)
      assert is_list(result.warnings)
      assert length(result.dependencies) == 2
    end

    test "returns fail when dependencies have violations" do
      deps = [
        %{name: "jason", licenses: ["Apache-2.0"]},
        %{name: "gpl_package", licenses: ["GPL-3.0"]}
      ]

      config = %{ignored_packages: [], project_license: nil}

      result = Compatibility.check_all("MIT", deps, config)

      assert result.status == :fail
      assert length(result.violations) == 1
      assert hd(result.violations) =~ "gpl_package"
      assert hd(result.violations) =~ "GPL-3.0"
    end

    test "ignores packages in ignored_packages list" do
      deps = [
        %{name: "jason", licenses: ["Apache-2.0"]},
        %{name: "gpl_package", licenses: ["GPL-3.0"]}
      ]

      config = %{ignored_packages: ["gpl_package"]}

      result = Compatibility.check_all("MIT", deps, config)

      assert result.status == :pass
      assert Enum.empty?(result.violations)
      assert length(result.dependencies) == 1
      assert hd(result.dependencies).name == "jason"
    end

    test "handles dependencies with multiple licenses" do
      deps = [
        %{name: "dual_licensed", licenses: ["MIT", "Apache-2.0"]}
      ]

      config = %{ignored_packages: [], project_license: nil}

      result = Compatibility.check_all("MIT", deps, config)

      assert result.status == :pass
      assert Enum.empty?(result.violations)
    end

    test "reports violations for each incompatible license in multi-licensed package" do
      deps = [
        %{name: "bad_dual", licenses: ["GPL-3.0", "AGPL-3.0"]}
      ]

      config = %{ignored_packages: [], project_license: nil}

      result = Compatibility.check_all("MIT", deps, config)

      assert result.status == :fail
      assert length(result.violations) == 2
    end

    test "handles empty dependencies list" do
      result = Compatibility.check_all("MIT", [], %{ignored_packages: []})

      assert result.status == :pass
      assert result.violations == []
      assert result.dependencies == []
    end

    test "handles nil project license" do
      deps = [%{name: "jason", licenses: ["Apache-2.0"]}]

      result = Compatibility.check_all(nil, deps, %{ignored_packages: [], project_license: nil})

      assert result.status == :pass
    end

    test "generates warning for unlicensed project" do
      deps = [%{name: "jason", licenses: ["Apache-2.0"]}]

      result = Compatibility.check_all(nil, deps, %{ignored_packages: [], project_license: nil})

      assert result.status == :pass
      assert length(result.warnings) == 1
      assert hd(result.warnings) =~ "no license"
      assert hd(result.warnings) =~ "proprietary"
    end

    test "generates warning for unlicensed dependencies" do
      deps = [
        %{name: "jason", licenses: ["Apache-2.0"]},
        %{name: "unlicensed_dep", licenses: ["Unknown-License"]}
      ]

      result = Compatibility.check_all("MIT", deps, %{ignored_packages: [], project_license: nil})

      assert result.status == :pass
      assert length(result.warnings) == 1
      assert hd(result.warnings) =~ "unlicensed_dep"
      assert hd(result.warnings) =~ "no legal right to use it"
    end

    test "proprietary project with permissive dependencies passes" do
      deps = [
        %{name: "jason", licenses: ["Apache-2.0"]},
        %{name: "plug", licenses: ["MIT"]}
      ]

      result =
        Compatibility.check_all("All Rights Reserved", deps, %{
          ignored_packages: [],
          project_license: nil
        })

      assert result.status == :pass
      assert Enum.empty?(result.violations)
    end

    test "proprietary project with copyleft dependencies fails" do
      deps = [
        %{name: "jason", licenses: ["Apache-2.0"]},
        %{name: "gpl_package", licenses: ["GPL-3.0"]}
      ]

      result =
        Compatibility.check_all("All Rights Reserved", deps, %{
          ignored_packages: [],
          project_license: nil
        })

      assert result.status == :fail
      assert length(result.violations) == 1
      assert hd(result.violations) =~ "gpl_package"
      assert hd(result.violations) =~ "proprietary project"
    end

    test "proprietary project with unlicensed dependencies fails" do
      deps = [
        %{name: "jason", licenses: ["Apache-2.0"]},
        %{name: "unlicensed_dep", licenses: ["Unknown-License"]}
      ]

      result =
        Compatibility.check_all("All Rights Reserved", deps, %{
          ignored_packages: [],
          project_license: nil
        })

      assert result.status == :fail
      assert length(result.violations) == 1
      assert hd(result.violations) =~ "unlicensed_dep"
      assert hd(result.violations) =~ "no legal right to use it"
    end
  end
end
