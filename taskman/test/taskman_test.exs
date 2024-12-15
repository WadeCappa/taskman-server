defmodule TaskmanTest do
  use ExUnit.Case
  doctest Taskman

  test "greets the world" do
    assert Taskman.hello() == :world
  end
end
