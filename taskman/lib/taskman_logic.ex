defmodule Taskman.Logic do

  defp get_required_fields(%{name: name, cost: cost, priority: priority}) do
    {:ok, %Taskman.Tasks{
      name: name,
      cost: cost,
      priority: priority
    }}
  end

  defp get_required_fields(malformed_request) do
    {:error, "missing required feilds!"}
  end

  defp add_with_default_from_request(task, request, field, default) do
    case Map.get(request, field, nil) do
      nil -> Map.put(task, field, default)
      _ -> task
    end
  end

  def task_from_request(request) do
    case get_required_fields(request) do
      {:ok, new_task} ->
        new_task
        |> add_with_default_from_request(request, :description, "")
        |> Map.put(:time_posted, System.os_time())
        |> Map.put(:status, Taskman.Status.to_number(:tracking))
      error -> error
    end
  end
end
