defmodule Taskman.Stores.Comments do
  import Ecto.Query

  def get_comments_for_tasks(tasks) do
    task_ids = Enum.map(tasks, fn t -> t.id end)

    comments =
      from(c in Taskman.Comments, where: c.task_id in ^task_ids)
      |> Taskman.Repo.all()
      |> Enum.sort(fn x, y -> x.time_posted_in_seconds < y.time_posted_in_seconds end)
      |> Enum.reverse()

    tasks
    |> Enum.map(fn t ->
      Map.put(t, :comments, Enum.filter(comments, fn c -> c.task_id == t.id end))
    end)
  end

  def new_comment(comment_text, task_id, user_id) do
    {status, resp} = Taskman.Stores.Tasks.get_task_by_id(task_id, user_id)

    if comment_text == :no_comment or status != :ok do
      {:error,
       %{
         reason: "cannot find task with provided task and user ids",
         user_id: user_id,
         task_id: task_id
       }}
    else
      %Taskman.Comments{
        content: comment_text,
        task_id: resp.id,
        time_posted_in_seconds: System.os_time(:second)
      }
      |> Taskman.Repo.insert(returning: true)
    end
  end
end
