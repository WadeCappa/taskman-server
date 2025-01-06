defmodule Taskman.Logic.Errors do
  @invalid_input_error %{error: %{reason: "invalid input"}}

  def get_invalid_input_error() do
    @invalid_input_error
  end
end
