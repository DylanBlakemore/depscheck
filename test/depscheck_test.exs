defmodule DepscheckTest do
  use ExUnit.Case
  doctest Depscheck

  describe "check/0" do
    test "returns a check result" do
      result = Depscheck.check()

      assert is_map(result)
      assert Map.has_key?(result, :status)
      assert Map.has_key?(result, :project_license)
      assert Map.has_key?(result, :dependencies)
      assert Map.has_key?(result, :violations)
      assert result.status in [:pass, :fail]
    end
  end

  describe "project_license/0" do
    test "returns project license or nil" do
      license = Depscheck.project_license()
      assert is_binary(license) or is_nil(license)
    end
  end

  describe "dependencies/0" do
    test "returns list of dependencies" do
      deps = Depscheck.dependencies()
      assert is_list(deps)
    end
  end
end
