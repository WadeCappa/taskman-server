defmodule Taskman.Stores.Tasks do

  import Ecto.Query

  # this needs to get comments and categories in one query. We should not
  #  load comments and categories seperatly, very expensive to do this
  def get_task_by_id(task_id, user_id) do
    task =
      from(t in Taskman.Tasks, where: t.id == ^task_id and t.user_id == ^user_id)
      |> Taskman.Repo.one()

    if task == nil do
      nil
    else
      task
      |> Map.put(:comments, Taskman.Stores.Comments.get_comments_for_task(task.id))
      |> Map.put(:categories, Taskman.Stores.Categories.get_categories_for_task(task.id))
    end
  end

  # select * from tasks left join comments on tasks.id = comments.task_id;
  # TODO: get this to work with ecto
  # TODO: these map calls are very expensive because we're not using joins
  def get_tasks(status_id, user_id, category) do
    category_id = Taskman.Stores.Categories.get_category_id(category, user_id)

    from(
      t in Taskman.Tasks,
      where: t.status == ^status_id and t.user_id == ^user_id
    )
    |> Taskman.Repo.all()
    |> Enum.map(fn t -> Map.put(t, :comments, Taskman.Stores.Comments.get_comments_for_task(t.id)) end)
    |> Enum.map(fn t -> Map.put(t, :categories, Taskman.Stores.Categories.get_categories_for_task(t.id)) end)
    |> Enum.filter(fn t -> has_category(t, category_id) end)
    |> then(fn tasks -> sort_tasks(tasks) end)
  end

  defp has_category(_, :none) do
    false
  end

  defp has_category(_, :all) do
    true
  end

  defp has_category(t, c_id) do
    t.categories
    |> Enum.map(fn c -> c.category_id end)
    |> then(fn cat_ids -> Enum.member?(cat_ids, c_id) end)
  end

  # this is kinda slow too, lots of repeat calculations. Can probably be faster.
  #  Might be able to cache this or something too since this only changes when a
  #  new task is added, which should be relatively rare, more reads than writes.
  defp sort_tasks(tasks) do
    total_priority =
      tasks
      |> Enum.reduce(1, fn task, p -> p + task.priority end)

    get_score = fn task ->
      time_to_deadline_cost =
        if task.deadline == nil do
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

  def insert_task(new_task, user_id, category_ids) do
    case new_task
        |> Taskman.Repo.insert(returning: true) do
      {:ok, task} -> insert_category_relations(task, category_ids, user_id)
      error -> error
    end
  end

  defp insert_category_relations(task, category_ids, user_id) do
    user_category_ids =
      user_id
      |> Taskman.Stores.Categories.get_categories_for_user()
      |> Enum.map(fn c -> c.category_id end)

    inserted_relations =
      category_ids
      |> Enum.filter(fn c_id -> Enum.member?(user_category_ids, c_id) end)
      |> Enum.map(fn c_id -> %Taskman.TasksToCategories{task_id: task.id, category_id: c_id} end)
      # TODO: should do this in one insert operation, look up how to do this
      |> Enum.map(fn x -> Taskman.Repo.insert(x, returning: true) end)
      |> Enum.filter(fn x ->
        case x do
          {:ok, _} -> true
          _error -> false
        end
      end)
      |> Enum.map(fn {:ok, x} -> x end)

    {:ok, Map.put(task, :categoryRelations, inserted_relations)}
  end

  def delete_task_by_id(task_id, user_id) do
    from(t in Taskman.Tasks, where: t.id == ^task_id and t.user_id == ^user_id)
    |> Taskman.Repo.delete_all()
  end

  def set_status(task_id, status, user_id) do
    from(
      t in Taskman.Tasks,
      where: t.id == ^task_id and t.user_id == ^user_id,
      update: [set: [status: ^status]]
    )
    |> Taskman.Repo.update_all([])
  end

end
