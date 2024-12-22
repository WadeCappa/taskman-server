defmodule TaskmanTest do
  use ExUnit.Case

  test "greets the world" do
    IO.puts Taskman.Status.to_number("completed")
    # assert Taskman.hello() == :world
  end
end
