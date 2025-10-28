defmodule Mix.Tasks.Depscheck do
  @shortdoc "Checks dependency licenses for compatibility"

  @moduledoc """
  Checks dependency licenses for compatibility with your project license.

  ## Usage

      mix depscheck

  ## Configuration

  Create a `.depscheck.exs` file in your project root:

      %{
        ignored_packages: ["some_package", "another_package"]
      }

  ## Exit Codes

  - 0: All dependencies are compatible
  - 1: License violations found
  """

  use Mix.Task

  alias Depscheck.{Compatibility, Config, LicenseDetector}

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("loadpaths")

    config = Config.load()
    project_license = LicenseDetector.get_project_license()
    dependencies = LicenseDetector.get_all_dependency_licenses()

    result = Compatibility.check_all(project_license, dependencies, config)

    print_results(result, config)

    if result.status == :fail do
      System.halt(1)
    end
  end

  # Private functions

  defp print_results(result, config) do
    project_name = Mix.Project.config()[:app] |> to_string() |> String.capitalize()
    license_display = result.project_license || "No license"

    IO.puts("\nChecking licenses for #{project_name} (#{license_display})...\n")

    ignored_set = MapSet.new(config.ignored_packages)

    # Print all dependencies
    all_deps = LicenseDetector.get_all_dependency_licenses()

    Enum.each(all_deps, fn dep ->
      cond do
        MapSet.member?(ignored_set, dep.name) ->
          print_ignored(dep)

        dep in result.dependencies ->
          print_dependency(dep, result)

        true ->
          # Shouldn't happen but handle gracefully
          print_dependency(dep, result)
      end
    end)

    # Print summary
    IO.puts("")

    case result.status do
      :pass ->
        IO.puts(IO.ANSI.green() <> "✓ All dependencies are compatible" <> IO.ANSI.reset())

      :fail ->
        violation_count = length(result.violations)

        IO.puts(
          IO.ANSI.red() <>
            "✗ Found #{violation_count} license violation(s)" <> IO.ANSI.reset()
        )

        IO.puts("\nViolations:")

        Enum.each(result.violations, fn violation ->
          IO.puts(IO.ANSI.red() <> "  • #{violation}" <> IO.ANSI.reset())
        end)
    end

    IO.puts("")
  end

  defp print_dependency(dep, result) do
    licenses_str = Enum.join(dep.licenses, ", ")
    has_violation = Enum.any?(result.violations, &String.contains?(&1, dep.name))

    if has_violation do
      IO.puts(
        IO.ANSI.red() <> "✗ #{dep.name} (#{licenses_str}) - INCOMPATIBLE" <> IO.ANSI.reset()
      )
    else
      IO.puts(
        IO.ANSI.green() <> "✓ #{dep.name} (#{licenses_str}) - Compatible" <> IO.ANSI.reset()
      )
    end
  end

  defp print_ignored(dep) do
    licenses_str = Enum.join(dep.licenses, ", ")
    IO.puts(IO.ANSI.yellow() <> "⊘ #{dep.name} (#{licenses_str}) - Ignored" <> IO.ANSI.reset())
  end
end
