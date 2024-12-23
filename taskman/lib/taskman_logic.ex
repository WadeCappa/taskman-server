defmodule Taskman.Logic do
  import Ecto.Query

  defp get_required_fields(%{name: name, cost: cost, priority: priority}) do
    {:ok,
     %Taskman.Tasks{
       name: name,
       cost: cost,
       priority: priority
     }}
  end

  defp get_required_fields(_malformed_request) do
    {:error, "missing required feilds!"}
  end

  def task_from_request(request) do
    case get_required_fields(request) do
      {:ok, new_task} ->
        new_task
        |> Map.put(:time_posted, System.os_time())
        |> Map.put(:status, 0)

      error ->
        error
    end
  end

  def set_status(task_id, status) do
    from(t in Taskman.Tasks, where: t.id == ^task_id, update: [set: [status: ^status]])
    |> Taskman.Repo.update_all([])
  end

  def get_tasks(status_id) do
    from(t in Taskman.Tasks, where: t.status == ^status_id)
    |> Taskman.Repo.all()
  end

  def delete_task_by_id(task_id) do
    from(t in Taskman.Tasks, where: t.id == ^task_id)
    |> Taskman.Repo.delete_all()
    |> IO.inspect()
  end

  def insert_task(new_task) do
    new_task
    |> task_from_request()
    |> Taskman.Repo.insert(returning: true)
  end
end
