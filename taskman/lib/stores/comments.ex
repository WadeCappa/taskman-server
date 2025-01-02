defmodule Taskman.Stores.Comments do
  import Ecto.Query

  def get_comments_for_task(task_id) do
    from(c in Taskman.Comments, where: c.task_id == ^task_id)
    |> Taskman.Repo.all()
    |> Enum.sort(fn x, y -> x.time_posted_in_seconds < y.time_posted_in_seconds end)
    |> Enum.reverse()
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
