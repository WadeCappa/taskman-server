defmodule Taskman.Logic.Status do
  @type status :: :tracking | :completed | :triaged

  @spec get_statuses() :: %{status() => integer()}
  defp get_statuses() do
    %{
      tracking: 0,
      completed: 1,
      triaged: 2
    }
  end

  @spec to_number_from_string(String.t()) :: integer()
  def to_number_from_string(status) do
    if Map.has_key?(get_statuses(), String.to_atom(status)) do
      {:ok, Map.get(get_statuses(), String.to_atom(status))}
    else
      :error
    end
  end
end
