defmodule Depscheck.LicenseDetector do
  @moduledoc """
  Detects licenses for the project and its dependencies.

  This module reads license information from:
  - Project's mix.exs for the project license
  - deps/*/hex_metadata.config for dependency licenses
  """

  alias Depscheck.Types

  @doc """
  Detects the project's license from mix.exs configuration.

  Returns the first license if multiple are declared, or nil if none found.

  ## Examples

      iex> Depscheck.LicenseDetector.get_project_license()
      "MIT"
  """
  @spec get_project_license() :: String.t() | nil
  def get_project_license do
    config = Mix.Project.config()
    get_license_from_config(config)
  end

  @doc """
  Detects the project's license with configuration override support.

  First checks for project_license in .depscheck.exs config, then falls back
  to mix.exs detection.

  ## Examples

      iex> Depscheck.LicenseDetector.get_project_license_with_config(%{project_license: "All Rights Reserved"})
      "All Rights Reserved"

      iex> Depscheck.LicenseDetector.get_project_license_with_config(%{project_license: nil})
      "MIT"
  """
  @spec get_project_license_with_config(Types.config()) :: String.t() | nil
  def get_project_license_with_config(config) do
    case config.project_license do
      nil -> get_project_license()
      license -> license
    end
  end

  @doc """
  Extracts all dependencies and their licenses from the deps directory.

  Returns a list of dependency maps with name and licenses.
  """
  @spec get_all_dependency_licenses() :: [Types.dependency()]
  def get_all_dependency_licenses do
    deps_path = Mix.Project.deps_path()

    case File.ls(deps_path) do
      {:ok, dep_dirs} ->
        dep_dirs
        |> Enum.map(&get_dependency_info(&1, deps_path))
        |> Enum.reject(&is_nil/1)

      {:error, _reason} ->
        []
    end
  end

  @doc """
  Gets license information for a single dependency.

  Returns {:ok, licenses} or {:error, reason}.
  """
  @spec get_dependency_license(String.t()) :: {:ok, [String.t()]} | {:error, atom()}
  def get_dependency_license(package_name) do
    package_name
    |> metadata_file()
    |> read_metadata()
    |> extract_licenses()
  end

  defp get_license_from_config(config) do
    case Keyword.get(config, :licenses) || Keyword.get(config, :license) do
      [license | _rest] when is_binary(license) -> license
      license when is_binary(license) -> license
      _other -> nil
    end
  end

  defp get_dependency_info(dep_name, _deps_path) do
    case get_dependency_license(dep_name) do
      {:ok, licenses} ->
        %{name: dep_name, licenses: licenses}

      {:error, _reason} ->
        nil
    end
  end

  defp metadata_file(package_name) do
    Mix.Project.deps_path()
    |> Path.join(package_name)
    |> Path.join("hex_metadata.config")
    |> String.to_charlist()
  end

  defp read_metadata(file_path) do
    case :file.consult(file_path) do
      {:ok, metadata} -> {:ok, metadata}
      {:error, reason} -> {:error, reason}
    end
  end

  defp extract_licenses({:ok, metadata}) do
    case List.keyfind(metadata, "licenses", 0) do
      {"licenses", licenses} when is_list(licenses) -> {:ok, licenses}
      {"licenses", _other} -> {:error, :invalid_licenses_format}
      nil -> {:error, :no_license_found}
    end
  end

  defp extract_licenses({:error, reason}), do: {:error, reason}
end
