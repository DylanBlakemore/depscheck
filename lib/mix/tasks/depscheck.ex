defmodule Mix.Tasks.Depscheck do
  @shortdoc "Checks dependency licenses for compatibility"

  @moduledoc """
  Checks dependency licenses for compatibility with your project license.

  ## Usage

      mix depscheck
      mix depscheck --verbose

  ## Configuration

  Create a `.depscheck.exs` file in your project root:

      %{
        ignored_packages: ["some_package", "another_package"],
        project_license: "All Rights Reserved"  # Override project license
      }

  ## Exit Codes

  - 0: All dependencies are compatible
  - 1: License violations found
  """

  use Mix.Task

  alias Depscheck.{Compatibility, Config, LicenseDetector}

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("loadpaths")

    verbose? = "--verbose" in args || "-v" in args

    config = Config.load()
    project_license = LicenseDetector.get_project_license_with_config(config)
    dependencies = LicenseDetector.get_all_dependency_licenses()

    result = Compatibility.check_all(project_license, dependencies, config)

    print_results(result, config, verbose?)

    if result.status == :fail do
      System.halt(1)
    end
  end

  # Private functions

  defp print_results(result, config, verbose?) do
    ignored_set = MapSet.new(config.ignored_packages)
    all_deps = LicenseDetector.get_all_dependency_licenses()

    if verbose? do
      print_verbose_results(result, ignored_set, all_deps)
    else
      print_minimal_results(result, ignored_set, all_deps)
    end
  end

  defp print_verbose_results(result, ignored_set, all_deps) do
    print_header(result)

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

    print_warnings(result)
    IO.puts("")
    print_summary(result, all_deps)
    IO.puts("")
  end

  defp print_minimal_results(result, ignored_set, all_deps) do
    has_failures = result.status == :fail
    has_warnings = !Enum.empty?(result.warnings)

    if has_failures || has_warnings do
      print_header(result)
    end

    print_violation_dependencies(result, ignored_set, all_deps)
    print_warnings(result)

    case result.status do
      :pass ->
        print_success_message(all_deps, has_warnings)

      :fail ->
        print_failure_summary(result)
    end
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

  defp print_header(result) do
    project_name = Mix.Project.config()[:app] |> to_string() |> String.capitalize()
    license_display = result.project_license || "No license"

    IO.puts("\nChecking licenses for #{project_name} (#{license_display})...\n")
  end

  defp print_warnings(result) do
    if !Enum.empty?(result.warnings) do
      IO.puts("")
      IO.puts(IO.ANSI.yellow() <> "Warnings:" <> IO.ANSI.reset())

      Enum.each(result.warnings, fn warning ->
        IO.puts(IO.ANSI.yellow() <> "  ⚠ #{warning}" <> IO.ANSI.reset())
      end)
    end
  end

  defp print_success_message(all_deps, include_blank_lines? \\ false) do
    if include_blank_lines? do
      IO.puts("")
    end

    message =
      IO.ANSI.green() <>
        "✓ All #{length(all_deps)} dependencies are compatible" <> IO.ANSI.reset()

    IO.puts(message)

    if include_blank_lines? do
      IO.puts("")
    end
  end

  defp print_failure_summary(result) do
    violation_count = length(result.violations)

    IO.puts("")

    IO.puts(
      IO.ANSI.red() <>
        "✗ Found #{violation_count} license violation(s)" <> IO.ANSI.reset()
    )

    IO.puts("\nViolations:")

    Enum.each(result.violations, fn violation ->
      IO.puts(IO.ANSI.red() <> "  • #{violation}" <> IO.ANSI.reset())
    end)

    IO.puts("")
  end

  defp print_summary(%{status: :pass}, all_deps) do
    print_success_message(all_deps)
  end

  defp print_summary(%{status: :fail}, all_deps) do
    print_failure_summary(all_deps)
  end

  defp print_violation_dependencies(result, ignored_set, all_deps) do
    all_deps
    |> Enum.filter(fn dep ->
      if MapSet.member?(ignored_set, dep.name) do
        false
      else
        Enum.any?(result.violations, &String.contains?(&1, dep.name))
      end
    end)
    |> Enum.each(fn dep ->
      print_dependency(dep, result)
    end)
  end
end
