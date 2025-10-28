defmodule Depscheck.Compatibility do
  @moduledoc """
  Checks license compatibility between project and dependencies.

  Implements the compatibility rules defined in LICENSE_COMPATIBILITY_RULES.md
  """

  alias Depscheck.{LicenseKnowledge, Types}

  @doc """
  Checks if a dependency license is compatible with the project license.

  Returns :compatible or {:incompatible, reason}.

  ## Examples

      iex> Depscheck.Compatibility.check_compatibility("MIT", "Apache-2.0")
      :compatible

      iex> Depscheck.Compatibility.check_compatibility("MIT", "GPL-3.0")
      {:incompatible, "Strong copyleft license GPL-3.0 cannot be used in permissive project"}
  """
  @spec check_compatibility(String.t() | nil, String.t()) ::
          :compatible | {:incompatible, String.t()}
  def check_compatibility(nil, _dep_license) do
    :compatible
  end

  def check_compatibility(project_license, dep_license) do
    project_category = LicenseKnowledge.get_category(project_license)
    dep_category = LicenseKnowledge.get_category(dep_license)

    check_categories(project_category, dep_category, project_license, dep_license)
  end

  @doc """
  Checks all dependencies against the project license.

  Returns a check_result map with status and violations.
  """
  @spec check_all(String.t() | nil, [Types.dependency()], Types.config()) ::
          Types.check_result()
  def check_all(project_license, dependencies, config) do
    ignored = MapSet.new(config.ignored_packages)

    {violations, checked_deps} =
      dependencies
      |> Enum.reject(fn dep -> MapSet.member?(ignored, dep.name) end)
      |> Enum.reduce({[], []}, fn dep, {violations_acc, deps_acc} ->
        dep_violations = check_dependency(project_license, dep)
        {violations_acc ++ dep_violations, [dep | deps_acc]}
      end)

    %{
      status: if(Enum.empty?(violations), do: :pass, else: :fail),
      project_license: project_license,
      dependencies: Enum.reverse(checked_deps),
      violations: violations
    }
  end

  # Unknown licenses - always compatible (warn but don't fail)
  defp check_categories(_proj_category, :unknown, _proj_lic, _dep_lic) do
    :compatible
  end

  defp check_categories(:unknown, _dep_category, _proj_lic, _dep_lic) do
    :compatible
  end

  # Permissive dependencies - always compatible
  defp check_categories(_proj_category, :permissive, _proj_lic, _dep_lic) do
    :compatible
  end

  # Strong copyleft dependencies - ONLY compatible with strong copyleft projects
  defp check_categories(:strong_copyleft, :strong_copyleft, _proj_lic, _dep_lic) do
    :compatible
  end

  defp check_categories(proj_category, :strong_copyleft, _proj_lic, dep_lic) do
    {:incompatible,
     "Strong copyleft license #{dep_lic} cannot be used in #{proj_category} project"}
  end

  # Weak copyleft dependencies - compatible with permissive, weak copyleft, and strong copyleft
  defp check_categories(proj_category, :weak_copyleft, _proj_lic, _dep_lic)
       when proj_category in [:permissive, :weak_copyleft, :strong_copyleft] do
    :compatible
  end

  # Permissive projects - can use anything except strong copyleft (handled above)
  defp check_categories(:permissive, _dep_category, _proj_lic, _dep_lic) do
    :compatible
  end

  # Weak copyleft projects - can use permissive and weak copyleft (handled above)
  defp check_categories(:weak_copyleft, _dep_category, _proj_lic, _dep_lic) do
    :compatible
  end

  # Strong copyleft projects - can use anything (handled above)
  defp check_categories(:strong_copyleft, _dep_category, _proj_lic, _dep_lic) do
    :compatible
  end

  defp check_dependency(project_license, dep) do
    dep.licenses
    |> Enum.flat_map(fn license ->
      case check_compatibility(project_license, license) do
        :compatible ->
          []

        {:incompatible, reason} ->
          ["#{dep.name} (#{license}): #{reason}"]
      end
    end)
  end
end
