defmodule Taskman.Stores.Categories do
  import Ecto.Query

  def get_categories_for_tasks(tasks, user_id) do
    task_ids = Enum.map(tasks, fn t -> t.id end)

    user_categories =
      user_id
      |> get_categories_for_user()
      |> Enum.reduce(%{}, fn c, acc -> Map.put(acc, c.category_id, c) end)

    relationships =
      from(t in Taskman.TasksToCategories, where: t.task_id in ^task_ids)
      |> Taskman.Repo.all()

    tasks
    |> Enum.map(fn t ->
      relationships_for_task =
        relationships
        |> Enum.filter(fn r -> r.task_id == t.id end)
        |> Enum.map(fn r -> Map.get(user_categories, r.category_id) end)

      Map.put(t, :categories, relationships_for_task)
    end)
  end

  def get_categories_for_user(user_id) do
    query = from(c in Taskman.Categories, where: c.user_id == ^user_id)
    Taskman.Repo.all(query)
  end

  def get_categories_for_user(user_id, status_id) do
    query =
      from(c in Taskman.Categories,
        left_join:
          s in subquery(
            from(m in Taskman.TasksToCategories,
              join: t in Taskman.Tasks,
              on: t.id == m.task_id,
              where: t.user_id == ^user_id and t.status == ^status_id,
              select: %{
                c_id: m.category_id,
                r_id: m.relationship_id
              }
            )
          ),
        on: c.category_id == s.c_id,
        where: c.user_id == ^user_id,
        group_by: :category_id,
        select: %{
          category_id: c.category_id,
          category_name: c.category_name,
          count: count(s.r_id)
        }
      )

    Taskman.Repo.all(query)
  end

  def try_create_category(category_name, user_id) do
    case get_category_id(category_name, user_id) do
      {:not_found, _reason} ->
        %Taskman.Categories{
          category_name: category_name,
          user_id: user_id
        }
        |> Taskman.Repo.insert(returning: true)

      _ ->
        {:error,
         %{
           reason: "category by this name already exists",
           user_id: user_id,
           category_name: category_name
         }}
    end
  end

  # TODO: Should return a unique value. This is currently
  #  not enforced at the db level
  def get_category_id(name, user_id) do
    category =
      from(
        c in Taskman.Categories,
        where: c.category_name == ^name and c.user_id == ^user_id
      )
      |> Taskman.Repo.one()

    if is_nil(category) do
      {:not_found, %{reason: "could not find a category for this name", category_name: name}}
    else
      {:ok, category.category_id}
    end
  end
end
