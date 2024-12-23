defmodule AuthmanTest do
  use ExUnit.Case
  doctest Authman

  test "greets the world" do
    assert Authman.hello() == :world
  end
end
