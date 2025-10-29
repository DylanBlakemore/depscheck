defmodule Depscheck.LicenseKnowledge do
  @moduledoc """
  Knowledge base of software licenses and their categories.

  This module provides license categorization for compatibility checking.
  """

  alias Depscheck.Types

  @permissive_licenses [
    "MIT",
    "Apache-2.0",
    "BSD-2-Clause",
    "BSD-3-Clause",
    "ISC",
    "Unlicense"
  ]

  @weak_copyleft_licenses [
    "LGPL-2.1",
    "LGPL-3.0",
    "MPL-2.0",
    "EPL-2.0",
    "CDDL-1.0"
  ]

  @strong_copyleft_licenses [
    "GPL-2.0",
    "GPL-3.0",
    "AGPL-3.0"
  ]

  @proprietary_licenses [
    "All Rights Reserved",
    "Unlicensed",
    "Proprietary"
  ]

  @doc """
  Returns the category for a given license name.

  ## Examples

      iex> Depscheck.LicenseKnowledge.get_category("MIT")
      :permissive

      iex> Depscheck.LicenseKnowledge.get_category("GPL-3.0")
      :strong_copyleft

      iex> Depscheck.LicenseKnowledge.get_category("Unknown-License")
      :unknown
  """
  @spec get_category(String.t()) :: Types.license_category()
  def get_category(license_name) do
    normalized = normalize_license_name(license_name)

    cond do
      normalized in normalize_list(@permissive_licenses) -> :permissive
      normalized in normalize_list(@weak_copyleft_licenses) -> :weak_copyleft
      normalized in normalize_list(@strong_copyleft_licenses) -> :strong_copyleft
      normalized in normalize_list(@proprietary_licenses) -> :proprietary
      true -> :unknown
    end
  end

  @doc """
  Returns true if the license is permissive.

  ## Examples

      iex> Depscheck.LicenseKnowledge.permissive?("MIT")
      true

      iex> Depscheck.LicenseKnowledge.permissive?("GPL-3.0")
      false
  """
  @spec permissive?(String.t()) :: boolean()
  def permissive?(license_name) do
    get_category(license_name) == :permissive
  end

  @doc """
  Returns true if the license is copyleft (weak or strong).

  ## Examples

      iex> Depscheck.LicenseKnowledge.copyleft?("GPL-3.0")
      true

      iex> Depscheck.LicenseKnowledge.copyleft?("LGPL-3.0")
      true

      iex> Depscheck.LicenseKnowledge.copyleft?("MIT")
      false
  """
  @spec copyleft?(String.t()) :: boolean()
  def copyleft?(license_name) do
    category = get_category(license_name)
    category == :weak_copyleft or category == :strong_copyleft
  end

  @doc """
  Returns true if the license is proprietary.

  ## Examples

      iex> Depscheck.LicenseKnowledge.proprietary?("All Rights Reserved")
      true

      iex> Depscheck.LicenseKnowledge.proprietary?("MIT")
      false
  """
  @spec proprietary?(String.t()) :: boolean()
  def proprietary?(license_name) do
    get_category(license_name) == :proprietary
  end

  @doc """
  Lists all licenses in a given category.

  ## Examples

      iex> Depscheck.LicenseKnowledge.list_licenses_by_category(:permissive)
      ["MIT", "Apache-2.0", "BSD-2-Clause", "BSD-3-Clause", "ISC", "Unlicense"]
  """
  @spec list_licenses_by_category(Types.license_category()) :: [String.t()]
  def list_licenses_by_category(:permissive), do: @permissive_licenses
  def list_licenses_by_category(:weak_copyleft), do: @weak_copyleft_licenses
  def list_licenses_by_category(:strong_copyleft), do: @strong_copyleft_licenses
  def list_licenses_by_category(:proprietary), do: @proprietary_licenses
  def list_licenses_by_category(:unknown), do: []

  defp normalize_license_name(license_name) do
    license_name
    |> String.downcase()
    |> String.trim()
  end

  defp normalize_list(licenses) do
    Enum.map(licenses, &normalize_license_name/1)
  end
end
