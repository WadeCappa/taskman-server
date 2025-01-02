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

    case category do
      nil ->
        {:not_found, %{reason: "could not find a category for this name", category_name: name}}

      cat ->
        {:ok, cat.category_id}
    end
  end
end
