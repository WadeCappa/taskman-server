defmodule Taskman.Stores.Tasks do
  import Ecto.Query

  # this needs to get comments and categories in one query. We should not
  #  load comments and categories seperatly, very expensive to do this
  def get_task_by_id(task_id, user_id) do
    task =
      from(t in Taskman.Tasks, where: t.id == ^task_id and t.user_id == ^user_id)
      |> Taskman.Repo.one()

    if is_nil(task) do
      {:not_found, %{reason: "could not find task", user_id: user_id, task_id: task_id}}
    else
      [task_with_comments] = Taskman.Stores.Comments.get_comments_for_tasks([task])

      [task_with_categories] =
        Taskman.Stores.Categories.get_categories_for_tasks([task_with_comments], user_id)

      {:ok, task_with_categories}
    end
  end

  # select * from tasks left join comments on tasks.id = comments.task_id;
  # TODO: get this to work with ecto
  # TODO: these map calls are very expensive because we're not using joins
  def get_tasks(status_id, user_id, category_ids) do
    from(
      t in Taskman.Tasks,
      where: t.status == ^status_id and t.user_id == ^user_id
    )
    |> Taskman.Repo.all()
    |> Taskman.Stores.Categories.get_categories_for_tasks(user_id)
    |> Enum.filter(fn t -> has_category(t, category_ids) end)
    |> Taskman.Stores.Comments.get_comments_for_tasks()
  end

  defp has_category(_, []) do
    true
  end

  defp has_category(t, ids) do
    t.categories
    |> Enum.filter(fn c -> Enum.member?(ids, c.category_id) end)
    |> then(fn matches -> length(matches) > 0 end)
  end

  def insert_task(new_task, category_ids) do
    case new_task
         |> Taskman.Repo.insert(returning: true) do
      {:ok, task} -> insert_category_relations(task, category_ids)
      error -> error
    end
  end

  defp insert_category_relations(task, category_ids) do
    target_categories =
      task.user_id
      |> Taskman.Stores.Categories.get_categories_for_user()
      |> Enum.filter(fn c -> Enum.member?(category_ids, c.category_id) end)

    target_categories
    |> Enum.map(fn c ->
      %Taskman.TasksToCategories{task_id: task.id, category_id: c.category_id}
    end)
    # TODO: should do this in one insert operation, look up how to do this
    |> Enum.each(fn x -> Taskman.Repo.insert(x, returning: true) end)

    {:ok, Map.put(task, :categories, target_categories)}
  end

  def delete_task_by_id(task_id, user_id) do
    from(t in Taskman.Tasks, where: t.id == ^task_id and t.user_id == ^user_id)
    |> Taskman.Repo.delete_all()
  end

  def set_status(task_id, status, user_id) do
    time =
      case Taskman.Logic.Status.get_name(status) do
        :completed -> System.os_time(:second)
        _other -> nil
      end

    from(
      t in Taskman.Tasks,
      where: t.id == ^task_id and t.user_id == ^user_id,
      update: [set: [status: ^status, time_completed: ^time]]
    )
    |> Taskman.Repo.update_all([])
  end
end
