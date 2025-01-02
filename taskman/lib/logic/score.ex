defmodule Taskman.Logic.Score do
  # this is kinda slow too, lots of repeat calculations. Can probably be faster.
  #  Might be able to cache this or something too since this only changes when a
  #  new task is added, which should be relatively rare, more reads than writes.
  def sort_tasks(tasks) do
    total_priority =
      tasks
      |> Enum.reduce(1, fn task, p -> p + task.priority end)

    get_score = fn task ->
      time_to_deadline_cost =
        if is_nil(task.deadline) do
          0
        else
          task.cost / max(task.deadline - System.os_time(:second), 1)
        end

      normalized_priority_over_cost =
        :math.sqrt(:math.pow(task.priority, 2) / total_priority) / task.cost

      time_to_deadline_cost + normalized_priority_over_cost
    end

    tasks
    |> Enum.map(fn t -> Map.put(t, :score, get_score.(t)) end)
    |> Enum.sort(fn x, y -> x.score < y.score end)
    |> Enum.reverse()
  end
end
