defmodule Depscheck.ConfigTest do
  use ExUnit.Case, async: false

  alias Depscheck.Config

  @test_config_path ".depscheck.exs"

  setup do
    # Clean up test config file after each test
    on_exit(fn -> File.rm(@test_config_path) end)
    :ok
  end

  describe "load/0" do
    test "returns default config when no config file exists" do
      File.rm(@test_config_path)
      assert Config.load() == %{ignored_packages: [], project_license: nil}
    end

    test "loads valid config file" do
      config_content = """
      %{
        ignored_packages: ["package1", "package2"]
      }
      """

      File.write!(@test_config_path, config_content)

      config = Config.load()
      assert config.ignored_packages == ["package1", "package2"]
    end

    test "returns default for invalid config file" do
      config_content = """
      [:not, :a, :map]
      """

      File.write!(@test_config_path, config_content)

      assert Config.load() == %{ignored_packages: [], project_license: nil}
    end

    test "returns default when ignored_packages is missing" do
      config_content = """
      %{
        some_other_key: "value"
      }
      """

      File.write!(@test_config_path, config_content)

      assert Config.load() == %{ignored_packages: [], project_license: nil}
    end

    test "returns default for malformed file" do
      config_content = """
      %{
        ignored_packages: ["unclosed
      """

      File.write!(@test_config_path, config_content)

      assert Config.load() == %{ignored_packages: [], project_license: nil}
    end

    test "loads empty ignored_packages list" do
      config_content = """
      %{
        ignored_packages: []
      }
      """

      File.write!(@test_config_path, config_content)

      config = Config.load()
      assert config.ignored_packages == []
    end
  end

  describe "default/0" do
    test "returns default configuration" do
      assert Config.default() == %{ignored_packages: [], project_license: nil}
    end
  end
end
