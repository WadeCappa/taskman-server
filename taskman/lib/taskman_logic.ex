defmodule Taskman.Logic do

  defp get_required_fields(%{name: name, cost: cost, priority: priority}) do
    %Taskman.Tasks{
      name: name,
      cost: cost,
      priority: priority
    }
  end

  defp add_with_default_from_request(task, request, field, default) do
    if Map.has_key?(request, field) do
      Map.put(task, field, Map.get(request, field))
    else
      Map.put(task, field, default)
    end
  end

  defp task_from_request(request) do
    get_required_fields(request)
    |> add_with_default_from_request(request, :description, "")
    |> Map.put(:time_posted, System.os_time())
    |> Map.put(:status, Taskman.Status.to_number(:tracking))
  end

  def get_tasks(status, _n) do
    Taskman.Repo.get_by(Taskman.Tasks, [status: status]) |> IO.inspect()
  end

  def put_task(request) do

  end
end
