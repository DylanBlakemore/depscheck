defmodule Depscheck.LicenseAliases do
  @moduledoc """
  Maps license spelling variations and aliases to canonical license names.

  This module provides a centralized mapping of common license name variations
  (e.g., "Apache v2.0", "GPLv2", "APL 2.0") to their canonical forms
  (e.g., "Apache-2.0", "GPL-2.0").

  ## Usage

  The aliases are used during license normalization to ensure that different
  spellings of the same license are correctly identified.

  ## Examples

      iex> Depscheck.LicenseAliases.resolve("apache-v2.0")
      "apache-2-0"

      iex> Depscheck.LicenseAliases.resolve("gplv2")
      "gpl-2-0"

      iex> Depscheck.LicenseAliases.resolve("apl-2.0")
      "apache-2-0"
  """

  # Mapping of license spelling variations/aliases to canonical names
  # Keys should be normalized (lowercase, trimmed) for matching
  # Values should use dash-separated version numbers (e.g., "2-0" not "2.0")
  # because normalize_common_variations converts "2.0" to "2-0"
  @aliases %{
    # Apache 2.0 variations
    "apache-v2.0" => "apache-2-0",
    "apache-v2-0" => "apache-2-0",
    "apache-2.0" => "apache-2-0",
    "apache-v2" => "apache-2-0",
    "apache2" => "apache-2-0",
    "apache2.0" => "apache-2-0",
    # APL (typo/variation) -> Apache
    "apl-2.0" => "apache-2-0",
    "apl-2-0" => "apache-2-0",
    "apl-v2.0" => "apache-2-0",
    "apl-v2-0" => "apache-2-0",
    "apl-v2" => "apache-2-0",
    "apl2" => "apache-2-0",
    "apl2.0" => "apache-2-0",
    # GPL-2.0 variations
    "gplv2" => "gpl-2-0",
    "gpl-v2" => "gpl-2-0",
    "gpl-v2.0" => "gpl-2-0",
    "gpl-v2-0" => "gpl-2-0",
    "gpl2" => "gpl-2-0",
    "gpl2.0" => "gpl-2-0",
    # GPL-3.0 variations
    "gplv3" => "gpl-3-0",
    "gpl-v3" => "gpl-3-0",
    "gpl-v3.0" => "gpl-3-0",
    "gpl-v3-0" => "gpl-3-0",
    "gpl3" => "gpl-3-0",
    "gpl3.0" => "gpl-3-0",
    # LGPL-2.1 variations
    "lgplv2.1" => "lgpl-2-1",
    "lgpl-v2.1" => "lgpl-2-1",
    "lgpl-v2-1" => "lgpl-2-1",
    "lgpl2.1" => "lgpl-2-1",
    # LGPL-3.0 variations
    "lgplv3" => "lgpl-3-0",
    "lgpl-v3" => "lgpl-3-0",
    "lgpl-v3.0" => "lgpl-3-0",
    "lgpl-v3-0" => "lgpl-3-0",
    "lgpl3" => "lgpl-3-0",
    "lgpl3.0" => "lgpl-3-0",
    # AGPL-3.0 variations
    "agplv3" => "agpl-3-0",
    "agpl-v3" => "agpl-3-0",
    "agpl-v3.0" => "agpl-3-0",
    "agpl-v3-0" => "agpl-3-0",
    "agpl3" => "agpl-3-0",
    "agpl3.0" => "agpl-3-0",
    # BSD variations
    "bsdv2" => "bsd-2-clause",
    "bsd-2" => "bsd-2-clause",
    "bsdv3" => "bsd-3-clause",
    "bsd-3" => "bsd-3-clause",
    "bsdv4" => "bsd-4-clause",
    "bsd-4" => "bsd-4-clause",
    # BSD-0-Clause / 0BSD variations
    "bsdv0" => "0bsd",
    "bsd-0" => "0bsd",
    "bsd-0-clause" => "0bsd",
    "bsd0" => "0bsd",
    "0bsd" => "0bsd",
    "zero-clause-bsd" => "0bsd",
    "bsd-zero-clause" => "0bsd",
    # MPL-2.0 variations
    "mplv2" => "mpl-2-0",
    "mpl-v2" => "mpl-2-0",
    "mpl-v2.0" => "mpl-2-0",
    "mpl-v2-0" => "mpl-2-0",
    "mpl2" => "mpl-2-0",
    "mpl2.0" => "mpl-2-0",
    # CC0-1.0 (public domain dedication) variations
    "cc0" => "cc0-1-0",
    "cc-0" => "cc0-1-0",
    "cc0-1-0-universal" => "cc0-1-0",
    "public-domain" => "cc0-1-0",
    "publicdomain" => "cc0-1-0"
  }

  @doc """
  Resolves a normalized license name to its canonical form.

  Returns the canonical license name if an alias exists, otherwise returns
  the input unchanged.

  ## Examples

      iex> Depscheck.LicenseAliases.resolve("apache-v2.0")
      "apache-2.0"

      iex> Depscheck.LicenseAliases.resolve("gplv2")
      "gpl-2.0"

      iex> Depscheck.LicenseAliases.resolve("unknown-license")
      "unknown-license"
  """
  @spec resolve(String.t()) :: String.t()
  def resolve(normalized_name) do
    Map.get(@aliases, normalized_name, normalized_name)
  end
end
