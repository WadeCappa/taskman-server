defmodule Taskman.Test.Status do
  use ExUnit.Case

  test "verifies status translations" do
    assert Taskman.Logic.Status.to_number_from_string("tracking") == {:ok, 0}
    assert Taskman.Logic.Status.to_number_from_string("completed") == {:ok, 1}
    assert Taskman.Logic.Status.to_number_from_string("triaged") == {:ok, 2}
  end

  test "verify getting status atom from number" do
    assert Taskman.Logic.Status.get_name(0) == :tracking
    assert Taskman.Logic.Status.get_name(1) == :completed
    assert Taskman.Logic.Status.get_name(2) == :triaged
    assert Taskman.Logic.Status.get_name(3) == :not_found
  end
end
