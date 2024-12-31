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

  def task_from_request(request, user_id) do
    case get_required_fields(request) do
      {:ok, new_task} ->
        new_task
        |> Map.put(:time_posted, System.os_time(:second))
        |> Map.put(:status, 0)
        |> Map.put(:user_id, user_id)

      error -> error
    end
  end

  def set_status(task_id, status, user_id) do
    from(
      t in Taskman.Tasks,
      where: t.id == ^task_id and t.user_id == ^user_id,
      update: [set: [status: ^status]])
    |> Taskman.Repo.update_all([])
  end

  def get_tasks(status_id, user_id) do
    from(t in Taskman.Tasks, where: t.status == ^status_id and t.user_id == ^user_id)
    |> Taskman.Repo.all()
  end

  def get_task_by_id(task_id, user_id) do
    from(t in Taskman.Tasks, where: t.id == ^task_id and t.user_id == ^user_id)
    |> Taskman.Repo.one()
  end

  def delete_task_by_id(task_id, user_id) do
    from(t in Taskman.Tasks, where: t.id == ^task_id and t.user_id == ^user_id)
    |> Taskman.Repo.delete_all()
  end

  def insert_task(new_task, user_id) do
    new_task
    |> task_from_request(user_id)
    |> Taskman.Repo.insert(returning: true)
  end

  def sort_tasks(tasks) do
    total_priority = tasks
    |> Enum.reduce(1, fn task, p -> p + task.priority end)
    |> IO.inspect()

    get_score = fn task ->
      time_to_deadline_cost = if task.deadline == nil do
        0
      else
        task.cost / max(task.deadline - System.os_time(:second), 1)
      end

      normalized_priority_over_cost = :math.sqrt(:math.pow(task.priority, 2) / total_priority) / task.cost
      time_to_deadline_cost + normalized_priority_over_cost
    end

    tasks
    |> Enum.map(fn t -> Map.put(t, :score, get_score.(t)) end)
    |> Enum.sort(fn x, y -> x.score < y.score end)
    |> Enum.reverse()
  end
end
