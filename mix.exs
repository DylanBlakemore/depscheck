defmodule Depscheck.MixProject do
  use Mix.Project

  def project do
    [
      app: :depscheck,
      version: "1.0.9",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: dialyzer(),

      # Hex
      description: description(),
      package: package(),

      # Docs
      name: "Depscheck",
      source_url: "https://github.com/dylanblakemore/depscheck",
      homepage_url: "https://github.com/dylanblakemore/depscheck",
      docs: docs(),
      licenses: ["MIT"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:versionise, "~> 1.0.0", only: [:dev], runtime: false}
    ]
  end

  defp description do
    """
    A CI/CD tool for checking dependency license compatibility in Elixir projects.
    Reads license information from local hex metadata files and validates compatibility
    with your project's license using industry-standard rules.
    """
  end

  defp package do
    [
      name: "depscheck",
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/dylanblakemore/depscheck",
        "Changelog" => "https://github.com/dylanblakemore/depscheck/blob/main/CHANGELOG.md"
      },
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE CHANGELOG.md
                LICENSE_COMPATIBILITY_RULES.md .depscheck.exs.example)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "LICENSE_COMPATIBILITY_RULES.md",
        "CHANGELOG.md"
      ],
      source_ref: "v1.0.9"
    ]
  end

  defp aliases do
    [
      precommit: ["format --check-formatted", "test", "credo --strict", "dialyzer"]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      plt_add_apps: [:mix, :ex_unit],
      flags: [:error_handling, :underspecs],
      ignore_warnings: ".dialyzer_ignore.exs"
    ]
  end
end
