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
      :none ->
        %Taskman.Categories{
          category_name: category_name,
          user_id: user_id
        }
        |> Taskman.Repo.insert(returning: true)

      _id ->
        {:error,
         %{reason: "category by this name already exists", user_id: user_id, category_name: category_name}}
    end
  end

  def get_category_id(:all, _usr_id) do
    :all
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
      nil -> :none
      cat -> cat.category_id
    end
  end

end
