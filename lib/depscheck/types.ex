defmodule Depscheck.Types do
  @moduledoc """
  Type definitions for Depscheck.
  """

  @type license_category :: :permissive | :weak_copyleft | :strong_copyleft | :unknown

  @type dependency :: %{
          name: String.t(),
          licenses: [String.t()]
        }

  @type check_result :: %{
          status: :pass | :fail,
          project_license: String.t() | nil,
          dependencies: [dependency()],
          violations: [String.t()]
        }

  @type config :: %{
          ignored_packages: [String.t()]
        }
end
