defmodule DepscheckTest do
  use ExUnit.Case
  doctest Depscheck

  test "greets the world" do
    assert Depscheck.hello() == :world
  end
end
