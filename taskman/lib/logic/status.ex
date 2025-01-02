defmodule Taskman.Logic.Status do
  @status_atoms_to_nums %{
    tracking: 0,
    completed: 1,
    triaged: 2
  }

  @status_nums_to_atoms @status_atoms_to_nums |> Map.new(fn {k, v} -> {v, k} end)

  @type status :: :tracking | :completed | :triaged

  # visible for testing
  @spec get_statuses() :: %{status() => integer()}
  def get_statuses() do
    @status_atoms_to_nums
  end

  @spec to_number_from_string(String.t()) :: integer()
  def to_number_from_string(status) do
    if Map.has_key?(get_statuses(), String.to_atom(status)) do
      {:ok, Map.get(get_statuses(), String.to_atom(status))}
    else
      {:error,
       %{reason: "bad status, try 'tracking', 'completed', and 'triaged'", status_string: status}}
    end
  end

  def get_name(status) do
    Map.get(@status_nums_to_atoms, status, :not_found)
  end
end
