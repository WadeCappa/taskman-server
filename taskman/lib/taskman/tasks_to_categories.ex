defmodule Taskman.TasksToCategories do
  use Ecto.Schema

  @primary_key false
  @derive {Poison.Encoder, only: [:relationship_id, :task_id, :category_id]}
  schema "tasks_to_categories" do
    field(:relationship_id, :integer)
    field(:task_id, :integer)
    field(:category_id, :integer)
  end
end
