defmodule Taskman.Repo.Migrations.CategoriesForTasks do
  use Ecto.Migration

  def change do
    create table(:categories, primary_key: false) do
      add :category_id, :identity, primary_key: true, start_value: 100, increment: 1
      add :category_name, :text, null: false
      add :user_id, :bigint, null: false
    end

    create table(:tasks_to_categories, primary_key: false) do
      add :relationship_id, :identity, primary_key: true, start_value: 100, increment: 1
      add :task_id, references(:tasks, on_delete: :delete_all), null: false
      add :category_id, references(:categories, on_delete: :delete_all), null: false
    end

    create index(:tasks_to_categories, [:task_id])
    create index(:tasks_to_categories, [:category_id, :user_id])
    create index(:categories, [:category_name])
  end
end
