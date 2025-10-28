defmodule Mix.Tasks.Version do
  @shortdoc "Bumps the version number"

  @moduledoc """
  Bumps the version number in mix.exs and updates related files.

  ## Usage

      mix version <major|minor|patch>

  ## Examples

      mix version patch  # 0.1.0 -> 0.1.1
      mix version minor  # 0.1.0 -> 0.2.0
      mix version major  # 0.1.0 -> 1.0.0

  This task will:
  - Update the version in mix.exs
  - Update the source_ref in docs
  - Add a new entry to CHANGELOG.md
  - Show you what changed
  """

  use Mix.Task

  @impl Mix.Task
  def run([bump_type]) when bump_type in ["major", "minor", "patch"] do
    current_version = get_current_version()
    new_version = bump_version(current_version, bump_type)

    IO.puts("")
    IO.puts(IO.ANSI.cyan() <> "=== Version Bump ===" <> IO.ANSI.reset())
    IO.puts("Current version: #{current_version}")
    IO.puts("New version: #{new_version}")
    IO.puts("")

    unless Mix.shell().yes?("Continue with version #{new_version}?") do
      IO.puts("Cancelled.")
      System.halt(0)
    end

    # Step 1: Update files
    IO.puts("")
    IO.puts(IO.ANSI.cyan() <> "=== Updating Files ===" <> IO.ANSI.reset())
    update_mix_exs(current_version, new_version)

    # Step 2: Collect changelog entries
    IO.puts("")
    IO.puts(IO.ANSI.cyan() <> "=== Changelog Entries ===" <> IO.ANSI.reset())
    changelog_entries = collect_changelog_entries()

    update_changelog(new_version, changelog_entries)

    # Step 3: Run tests
    IO.puts("")
    IO.puts(IO.ANSI.cyan() <> "=== Running Tests ===" <> IO.ANSI.reset())

    if Mix.shell().yes?("Run test suite (mix precommit)?") do
      IO.puts("Running mix precommit...")

      {output, exit_code} =
        System.cmd("mix", ["precommit"], env: [{"MIX_ENV", "test"}], stderr_to_stdout: true)

      IO.puts(output)

      if exit_code != 0 do
        IO.puts("")
        IO.puts(IO.ANSI.red() <> "✗ Tests failed!" <> IO.ANSI.reset())
        IO.puts("Fix the issues and run the release process again.")
        System.halt(1)
      end

      IO.puts("")
      IO.puts(IO.ANSI.green() <> "✓ All tests passed!" <> IO.ANSI.reset())
    else
      IO.puts(
        IO.ANSI.yellow() <>
          "⚠ Skipping tests - make sure to run them before publishing!" <> IO.ANSI.reset()
      )
    end

    # Step 4: Git operations
    IO.puts("")
    IO.puts(IO.ANSI.cyan() <> "=== Git Operations ===" <> IO.ANSI.reset())

    if Mix.shell().yes?("Commit changes and create git tag?") do
      perform_git_operations(new_version)
    else
      IO.puts("")
      IO.puts(IO.ANSI.yellow() <> "Skipping git operations." <> IO.ANSI.reset())
      IO.puts("To commit manually:")
      IO.puts("  git add .")
      IO.puts("  git commit -m 'Release v#{new_version}'")
      IO.puts("  git tag v#{new_version}")
      IO.puts("  git push origin main --tags")
    end

    # Step 5: Hex publish
    IO.puts("")
    IO.puts(IO.ANSI.cyan() <> "=== Hex Publishing ===" <> IO.ANSI.reset())

    if Mix.shell().yes?("Publish to Hex.pm?") do
      IO.puts("Running mix hex.publish...")
      System.cmd("mix", ["hex.publish"], into: IO.stream(:stdio, :line))
    else
      IO.puts("")
      IO.puts(IO.ANSI.yellow() <> "Skipping Hex publish." <> IO.ANSI.reset())
      IO.puts("To publish manually: mix hex.publish")
    end

    IO.puts("")
    IO.puts(IO.ANSI.green() <> "✓ Release process complete!" <> IO.ANSI.reset())
    IO.puts("")
    IO.puts("Don't forget to create a GitHub release:")
    IO.puts("  https://github.com/dylanblakemore/depscheck/releases/new")
  end

  def run([]) do
    IO.puts("Usage: mix version <major|minor|patch>")
    IO.puts("")
    IO.puts("Examples:")
    IO.puts("  mix version patch  # Bump patch version (0.1.0 -> 0.1.1)")
    IO.puts("  mix version minor  # Bump minor version (0.1.0 -> 0.2.0)")
    IO.puts("  mix version major  # Bump major version (0.1.0 -> 1.0.0)")
  end

  def run(_opts) do
    IO.puts(IO.ANSI.red() <> "Error: Invalid bump type" <> IO.ANSI.reset())
    IO.puts("Use: major, minor, or patch")
    System.halt(1)
  end

  defp get_current_version do
    Mix.Project.config()[:version]
  end

  defp bump_version(version, bump_type) do
    [major, minor, patch] =
      version
      |> String.split(".")
      |> Enum.map(&String.to_integer/1)

    case bump_type do
      "major" -> "#{major + 1}.0.0"
      "minor" -> "#{major}.#{minor + 1}.0"
      "patch" -> "#{major}.#{minor}.#{patch + 1}"
    end
  end

  defp update_mix_exs(old_version, new_version) do
    mix_exs_path = "mix.exs"
    content = File.read!(mix_exs_path)

    # Update version
    content =
      String.replace(content, ~s(version: "#{old_version}"), ~s(version: "#{new_version}"))

    # Update source_ref in docs
    content =
      String.replace(
        content,
        ~s(source_ref: "v#{old_version}"),
        ~s(source_ref: "v#{new_version}")
      )

    File.write!(mix_exs_path, content)
    IO.puts("✓ Updated mix.exs")
  end

  defp collect_changelog_entries do
    IO.puts("Enter changelog entries (press Enter with empty line to skip a section)")
    IO.puts("")

    added = collect_section("Added", "New features or functionality")
    changed = collect_section("Changed", "Changes to existing functionality")
    fixed = collect_section("Fixed", "Bug fixes")

    %{added: added, changed: changed, fixed: fixed}
  end

  defp collect_section(section_name, description) do
    IO.puts(IO.ANSI.yellow() <> "#{section_name}" <> IO.ANSI.reset() <> " (#{description})")
    collect_items([])
  end

  defp collect_items(items) do
    case IO.gets("  - ") |> String.trim() do
      "" ->
        Enum.reverse(items)

      item ->
        collect_items([item | items])
    end
  end

  defp update_changelog(new_version, entries) do
    changelog_path = "CHANGELOG.md"
    content = File.read!(changelog_path)

    today = Date.utc_today() |> Date.to_string()

    sections =
      [
        build_section("Added", entries.added),
        build_section("Changed", entries.changed),
        build_section("Fixed", entries.fixed)
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\n")

    new_entry =
      if sections != "" do
        """
        ## [#{new_version}] - #{today}

        #{sections}

        """
      else
        """
        ## [#{new_version}] - #{today}

        No changes documented.

        """
      end

    lines = String.split(content, "\n")

    {before_entries, entries_list} =
      Enum.split_while(lines, fn line ->
        not String.starts_with?(line, "## [")
      end)

    updated_content =
      (before_entries ++ [new_entry] ++ entries_list)
      |> Enum.join("\n")

    File.write!(changelog_path, updated_content)
    IO.puts("✓ Updated CHANGELOG.md")
  end

  defp build_section(_name, []), do: nil

  defp build_section(name, items) do
    items_text = Enum.map_join(items, "\n", &"- #{&1}")

    """
    ### #{name}

    #{items_text}
    """
  end

  defp perform_git_operations(version) do
    IO.puts("Staging changes...")
    System.cmd("git", ["add", "."])

    IO.puts("Committing...")
    System.cmd("git", ["commit", "-m", "Release v#{version}"])

    IO.puts("Creating tag...")
    System.cmd("git", ["tag", "v#{version}"])

    IO.puts("")

    if Mix.shell().yes?("Push to origin?") do
      IO.puts("Pushing to origin...")
      System.cmd("git", ["push", "origin", "main"])
      System.cmd("git", ["push", "origin", "v#{version}"])
      IO.puts(IO.ANSI.green() <> "✓ Pushed to origin" <> IO.ANSI.reset())
    else
      IO.puts("")
      IO.puts(IO.ANSI.yellow() <> "Skipping push." <> IO.ANSI.reset())
      IO.puts("To push manually:")
      IO.puts("  git push origin main")
      IO.puts("  git push origin v#{version}")
    end
  end
end
