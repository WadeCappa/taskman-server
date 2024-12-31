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

      error ->
        error
    end
  end

  def set_status(task_id, status, user_id) do
    from(
      t in Taskman.Tasks,
      where: t.id == ^task_id and t.user_id == ^user_id,
      update: [set: [status: ^status]]
    )
    |> Taskman.Repo.update_all([])
  end

  defp get_comments(task_id) do
    from(c in Taskman.Comments, where: c.task_id == ^task_id)
    |> Taskman.Repo.all()
    |> Enum.sort(fn x, y -> x.time_posted_in_seconds < y.time_posted_in_seconds end)
    |> Enum.reverse()
  end

  defp has_category(_, :all) do
    true
  end

  defp has_category(t, c_id) do
    Enum.member?(t.categories, c_id)
  end

  defp get_category_id(:all) do
    :all
  end

  defp get_category_id(name) do
    category = from(c in Taskman.Categories, where: c.category_name == ^name)
    |> Taskman.Repo.one()

    case category do
      nil -> :all
      cat -> cat.category_id
    end
  end

  defp get_categories(task_id) do
    from(
      c in Taskman.Categories,
      join: t in Taskman.TasksToCategories, on: t.task_id == c.task_id,
      where: c.task_id == ^task_id)
    |> Taskman.Repo.all()
  end

  def get_tasks(status_id, user_id, category) do
    # select * from tasks left join comments on tasks.id = comments.task_id;
    # TODO: get this to work with ecto
    # TODO: these map calls are very expensive because we're not using joins
    category_id = get_category_id(category)

    from(
      t in Taskman.Tasks,
      where: t.status == ^status_id and t.user_id == ^user_id
    )
    |> Taskman.Repo.all()
    |> Enum.map(fn t -> Map.put(t, :comments, get_categories(t.id)) end)
    |> Enum.map(fn t -> Map.put(t, :categories, get_comments(t.id)) end)
    |> Enum.filter(fn t -> has_category(t, category_id) end)
  end

  def get_task_by_id(task_id, user_id) do
    task =
      from(t in Taskman.Tasks, where: t.id == ^task_id and t.user_id == ^user_id)
      |> Taskman.Repo.one()

    if task == nil do
      nil
    else
      Map.put(task, :comments, get_comments(task.id))
    end
  end

  def delete_task_by_id(task_id, user_id) do
    from(t in Taskman.Tasks, where: t.id == ^task_id and t.user_id == ^user_id)
    |> Taskman.Repo.delete_all()
  end

  def get_categories_for_user(user_id) do
    from(c in Taskman.Categories, where: c.user_id == ^user_id)
    |> Taskman.Repo.all()
  end

  defp insert_category_relations(task, category_ids, user_id) do
    user_category_ids =
      user_id
      |> get_categories_for_user()
      |> Enum.map(fn c -> c.category_id end)

    inserted_relations =
      category_ids
      |> Enum.filter(fn c_id -> Enum.member?(user_category_ids, c_id) end)
      |> Enum.map(fn c_id -> %Taskman.TasksToCategories{task_id: task.id, category_id: c_id} end)
      |> Taskman.Repo.insert(returning: true)

    case inserted_relations do
      {:ok, relations} ->
        inserted_ids = Enum.map(relations, fn x -> x.category_id end)
        Map.put(task, :categories, inserted_ids)

      error ->
        error
    end
  end

  def insert_task(new_task, user_id, category_ids) do
    case new_task
         |> task_from_request(user_id)
         |> Taskman.Repo.insert(returning: true) do
      {:ok, task} -> insert_category_relations(task, category_ids, user_id)
      error -> error
    end
  end

  def sort_tasks(tasks) do
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

  def new_comment(content, task_id, user_id) do
    case Integer.parse(task_id) do
      {num, ""} ->
        if content == :no_comment or get_task_by_id(num, user_id) == nil do
          {:error,
           %{
             reason: "cannot find task with provided task and user ids",
             user_id: user_id,
             task_id: num
           }}
        else
          %Taskman.Comments{
            content: content,
            task_id: num,
            time_posted_in_seconds: System.os_time(:second)
          }
          |> Taskman.Repo.insert(returning: true)
        end

      _ ->
        {:error,
         %{
           reason: "did not pass a valid task_id",
           task_id: task_id
         }}
    end
  end
end
