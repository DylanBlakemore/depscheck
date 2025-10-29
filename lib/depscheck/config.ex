defmodule Depscheck.Config do
  @moduledoc """
  Configuration management for Depscheck.

  Loads configuration from `.depscheck.exs` file in the project root.

  ## Example Config File

      # .depscheck.exs
      %{
        ignored_packages: ["some_package", "another_package"]
      }
  """

  alias Depscheck.Types

  @config_filename ".depscheck.exs"

  @default_config %{
    ignored_packages: [],
    project_license: nil
  }

  @doc """
  Loads configuration from .depscheck.exs file.

  Returns default configuration if file doesn't exist.

  ## Examples

      iex> Depscheck.Config.load()
      %{ignored_packages: []}
  """
  @spec load() :: Types.config()
  def load do
    config_path = Path.join(File.cwd!(), @config_filename)

    if File.exists?(config_path) do
      load_config_file(config_path)
    else
      @default_config
    end
  end

  @doc """
  Returns the default configuration.
  """
  @spec default() :: Types.config()
  def default, do: @default_config

  defp load_config_file(path) do
    {config, _binding} = Code.eval_file(path)

    if is_map(config) do
      known_keys = Map.keys(@default_config)
      filtered_config = Map.take(config, known_keys)
      Map.merge(@default_config, filtered_config)
    else
      @default_config
    end
  rescue
    _error -> @default_config
  end
end
