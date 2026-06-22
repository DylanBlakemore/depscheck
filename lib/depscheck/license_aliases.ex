defmodule Depscheck.LicenseAliases do
  @moduledoc """
  Maps license spelling variations and aliases to canonical license names.

  This module provides a centralized mapping of common license name variations
  (e.g., "Apache v2.0", "GPLv2", "APL 2.0") to their canonical forms
  (e.g., "Apache-2.0", "GPL-2.0").

  ## Usage

  The aliases are used during license normalization to ensure that different
  spellings of the same license are correctly identified.

  `resolve/1` expects its argument to already be normalized (lowercase, dashes
  for spaces, dash-separated version numbers), since it is the final step of the
  normalization pipeline. The examples below use that normalized form.

  ## Examples

      iex> Depscheck.LicenseAliases.resolve("apl-v2-0")
      "apache-2-0"

      iex> Depscheck.LicenseAliases.resolve("gplv2")
      "gpl-2-0"

      iex> Depscheck.LicenseAliases.resolve("gpl-3-0-only")
      "gpl-3-0"
  """

  # Mapping of license spelling variations/aliases to canonical names
  # Keys should be normalized (lowercase, trimmed) for matching
  # Values should use dash-separated version numbers (e.g., "2-0" not "2.0")
  # because normalize_common_variations converts "2.0" to "2-0"
  #
  # IMPORTANT: keys are matched *after* the rest of normalization has run, so
  # they must be written in fully-normalized form: lowercase, dashes instead of
  # spaces, and dash-separated version numbers ("2-0", never "2.0" — the dot is
  # already gone by the time `resolve/1` is called). A key containing a dot can
  # never match and is dead code.
  @aliases %{
    # Apache-2.0 variations
    "apache-v2-0" => "apache-2-0",
    "apache-v2" => "apache-2-0",
    "apache2" => "apache-2-0",
    "apache2-0" => "apache-2-0",
    # APL (typo/variation) -> Apache
    "apl-2-0" => "apache-2-0",
    "apl-v2-0" => "apache-2-0",
    "apl-v2" => "apache-2-0",
    "apl2" => "apache-2-0",
    "apl2-0" => "apache-2-0",
    # GPL-1.0 variations
    "gplv1" => "gpl-1-0",
    "gpl-v1" => "gpl-1-0",
    "gpl1" => "gpl-1-0",
    "gpl-1-0-only" => "gpl-1-0",
    "gpl-1-0-or-later" => "gpl-1-0",
    "gpl-1-0+" => "gpl-1-0",
    # GPL-2.0 variations
    "gplv2" => "gpl-2-0",
    "gpl-v2" => "gpl-2-0",
    "gpl-v2-0" => "gpl-2-0",
    "gpl2" => "gpl-2-0",
    "gpl2-0" => "gpl-2-0",
    # SPDX deprecated the bare "GPL-2.0" in favour of explicit "-only"/
    # "-or-later" suffixes (and the legacy "+" operator). All map to the same
    # compatibility category.
    "gpl-2-0-only" => "gpl-2-0",
    "gpl-2-0-or-later" => "gpl-2-0",
    "gpl-2-0+" => "gpl-2-0",
    # GPL-3.0 variations
    "gplv3" => "gpl-3-0",
    "gpl-v3" => "gpl-3-0",
    "gpl-v3-0" => "gpl-3-0",
    "gpl3" => "gpl-3-0",
    "gpl3-0" => "gpl-3-0",
    "gpl-3-0-only" => "gpl-3-0",
    "gpl-3-0-or-later" => "gpl-3-0",
    "gpl-3-0+" => "gpl-3-0",
    # LGPL-2.0 variations
    "lgplv2" => "lgpl-2-0",
    "lgpl-v2" => "lgpl-2-0",
    "lgpl2" => "lgpl-2-0",
    "lgpl2-0" => "lgpl-2-0",
    "lgpl-2-0-only" => "lgpl-2-0",
    "lgpl-2-0-or-later" => "lgpl-2-0",
    "lgpl-2-0+" => "lgpl-2-0",
    # LGPL-2.1 variations
    "lgplv2-1" => "lgpl-2-1",
    "lgpl-v2-1" => "lgpl-2-1",
    "lgpl2-1" => "lgpl-2-1",
    "lgpl-2-1-only" => "lgpl-2-1",
    "lgpl-2-1-or-later" => "lgpl-2-1",
    "lgpl-2-1+" => "lgpl-2-1",
    # LGPL-3.0 variations
    "lgplv3" => "lgpl-3-0",
    "lgpl-v3" => "lgpl-3-0",
    "lgpl-v3-0" => "lgpl-3-0",
    "lgpl3" => "lgpl-3-0",
    "lgpl3-0" => "lgpl-3-0",
    "lgpl-3-0-only" => "lgpl-3-0",
    "lgpl-3-0-or-later" => "lgpl-3-0",
    "lgpl-3-0+" => "lgpl-3-0",
    # AGPL-3.0 variations
    "agplv3" => "agpl-3-0",
    "agpl-v3" => "agpl-3-0",
    "agpl-v3-0" => "agpl-3-0",
    "agpl3" => "agpl-3-0",
    "agpl3-0" => "agpl-3-0",
    "agpl-3-0-only" => "agpl-3-0",
    "agpl-3-0-or-later" => "agpl-3-0",
    "agpl-3-0+" => "agpl-3-0",
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
    # MPL-1.1 variations
    "mplv1-1" => "mpl-1-1",
    "mpl-v1-1" => "mpl-1-1",
    "mpl1-1" => "mpl-1-1",
    # MPL-2.0 variations
    "mplv2" => "mpl-2-0",
    "mpl-v2" => "mpl-2-0",
    "mpl-v2-0" => "mpl-2-0",
    "mpl2" => "mpl-2-0",
    "mpl2-0" => "mpl-2-0",
    # EPL (Eclipse Public License) variations
    "eplv1" => "epl-1-0",
    "epl1" => "epl-1-0",
    "eplv2" => "epl-2-0",
    "epl2" => "epl-2-0",
    # Boost Software License -> BSL-1.0
    "boost" => "bsl-1-0",
    "boost-1-0" => "bsl-1-0",
    "boost-software-license" => "bsl-1-0",
    "bsl" => "bsl-1-0",
    # Python Software Foundation / Python-2.0
    "python" => "python-2-0",
    "psf" => "psf-2-0",
    "psfl" => "psf-2-0",
    # SIL Open Font License -> OFL-1.1
    "ofl" => "ofl-1-1",
    "sil-ofl-1-1" => "ofl-1-1",
    "openfont" => "ofl-1-1",
    # Artistic License -> Artistic-2.0
    "artistic" => "artistic-2-0",
    "artistic-2" => "artistic-2-0",
    # Microsoft Public / Reciprocal License
    "mspl" => "ms-pl",
    "ms-public-license" => "ms-pl",
    "msrl" => "ms-rl",
    # Open Software License -> OSL-3.0
    "osl" => "osl-3-0",
    "osl3" => "osl-3-0",
    # EUPL (European Union Public License) variations
    "eupl" => "eupl-1-2",
    "eupl1-2" => "eupl-1-2",
    "eupl-v1-2" => "eupl-1-2",
    "eupl1-1" => "eupl-1-1",
    # Server Side Public License -> SSPL-1.0
    "sspl" => "sspl-1-0",
    "sspl-v1" => "sspl-1-0",
    # X11 -> distinct SPDX id but commonly conflated with MIT
    "mit-x11" => "x11",
    # WTFPL variations
    "wtfplv2" => "wtfpl",
    "wtfpl-2" => "wtfpl",
    # Zlib variations
    "zlib-libpng" => "zlib",
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

      iex> Depscheck.LicenseAliases.resolve("apl-v2-0")
      "apache-2-0"

      iex> Depscheck.LicenseAliases.resolve("gplv2")
      "gpl-2-0"

      iex> Depscheck.LicenseAliases.resolve("unknown-license")
      "unknown-license"
  """
  @spec resolve(String.t()) :: String.t()
  def resolve(normalized_name) do
    Map.get(@aliases, normalized_name, normalized_name)
  end
end
