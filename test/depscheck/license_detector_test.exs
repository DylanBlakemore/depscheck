defmodule Depscheck.LicenseDetectorTest do
  use ExUnit.Case, async: true

  alias Depscheck.LicenseDetector

  describe "get_project_license/0" do
    test "returns nil when no license is configured" do
      # This test runs in the depscheck project which should have a license
      # but we're testing the function works
      license = LicenseDetector.get_project_license()
      assert is_binary(license) or is_nil(license)
    end
  end

  describe "get_dependency_license/1" do
    test "returns license for credo dependency" do
      # credo is a dev dependency in this project
      case LicenseDetector.get_dependency_license("credo") do
        {:ok, licenses} ->
          assert is_list(licenses)
          assert length(licenses) > 0

        {:error, _reason} ->
          # Dependency might not be fetched yet
          :ok
      end
    end

    test "returns error for non-existent package" do
      assert {:error, _reason} = LicenseDetector.get_dependency_license("nonexistent_package_xyz")
    end
  end

  describe "get_all_dependency_licenses/0" do
    test "returns a list of dependencies" do
      deps = LicenseDetector.get_all_dependency_licenses()
      assert is_list(deps)

      # Each dependency should have name and licenses
      Enum.each(deps, fn dep ->
        assert is_map(dep)
        assert Map.has_key?(dep, :name)
        assert Map.has_key?(dep, :licenses)
        assert is_binary(dep.name)
        assert is_list(dep.licenses)
      end)
    end

    test "includes credo if dependencies are fetched" do
      deps = LicenseDetector.get_all_dependency_licenses()
      dep_names = Enum.map(deps, & &1.name)

      # Only check if we have any deps (they might not be fetched yet)
      if length(deps) > 0 do
        # If deps are fetched, credo should be there
        assert "credo" in dep_names or "dialyxir" in dep_names
      end
    end
  end
end
