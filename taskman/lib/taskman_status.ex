defmodule Taskman.Status do

  @type status :: :tracking | :completed | :triage

  @spec get_statuses() :: %{status() => integer()}
  defp get_statuses() do
    %{
      tracking: 0,
      completed: 1,
      triage: 2,
    }
  end

  @spec to_number(status()) :: integer()
  def to_number(status) do
    Map.get(get_statuses(), status)
  end
end
