defmodule Depscheck do
  @moduledoc """
  A tool for checking dependency license compatibility in Elixir projects.

  Depscheck helps ensure your project's dependencies have compatible licenses
  by reading license information from local hex_metadata.config files and
  checking them against your project's license.

  ## Usage

  Run the Mix task:

      mix depscheck

  Or use the API directly:

      Depscheck.check()

  ## Configuration

  Create a `.depscheck.exs` file in your project root to ignore specific packages:

      %{
        ignored_packages: ["some_package", "another_package"]
      }

  ## License Compatibility

  See LICENSE_COMPATIBILITY_RULES.md for detailed information about how
  license compatibility is determined.
  """

  alias Depscheck.{Compatibility, Config, LicenseDetector, Types}

  @doc """
  Checks all dependencies for license compatibility.

  Returns a check_result map with status and violations.

  ## Examples

      iex> result = Depscheck.check()
      iex> result.status
      :pass
  """
  @spec check() :: Types.check_result()
  def check do
    config = Config.load()
    project_license = LicenseDetector.get_project_license()
    dependencies = LicenseDetector.get_all_dependency_licenses()

    Compatibility.check_all(project_license, dependencies, config)
  end

  @doc """
  Gets the project's license from mix.exs.

  ## Examples

      iex> Depscheck.project_license()
      "MIT"
  """
  @spec project_license() :: String.t() | nil
  def project_license do
    LicenseDetector.get_project_license()
  end

  @doc """
  Gets all dependency licenses.

  ## Examples

      iex> deps = Depscheck.dependencies()
      iex> is_list(deps)
      true
  """
  @spec dependencies() :: [Types.dependency()]
  def dependencies do
    LicenseDetector.get_all_dependency_licenses()
  end
end
