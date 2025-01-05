defmodule Taskman.Stores.Categories do
  import Ecto.Query

  def get_categories_for_task(task_id) do
    from(
      c in Taskman.Categories,
      join: t in Taskman.TasksToCategories,
      on: t.category_id == c.category_id,
      where: t.task_id == ^task_id
    )
    |> Taskman.Repo.all()
  end

  def get_categories_for_user(user_id) do
    from(c in Taskman.Categories, where: c.user_id == ^user_id)
    |> Taskman.Repo.all()
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

  def insert_category_relations(task, category_ids) do
    target_categories =
      task.user_id
      |> get_categories_for_user()
      |> Enum.filter(fn c -> Enum.member?(category_ids, c.category_id) end)

    target_categories
    |> Enum.map(fn c ->
      %Taskman.TasksToCategories{task_id: task.id, category_id: c.category_id}
    end)
    # TODO: should do this in one insert operation, look up how to do this
    |> Enum.each(fn x -> Taskman.Repo.insert(x, returning: true) end)

    {:ok, Map.put(task, :categories, target_categories)}
  end
end
