defmodule TaskmanTest do
  use ExUnit.Case

  test "verifies status translations" do
    assert Taskman.Status.to_number_from_string("tracking") == {:ok, 0}
    assert Taskman.Status.to_number_from_string("completed") == {:ok, 1}
    assert Taskman.Status.to_number_from_string("triaged") == {:ok, 2}
  end
end
