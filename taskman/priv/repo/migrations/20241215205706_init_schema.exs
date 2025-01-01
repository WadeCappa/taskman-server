defmodule Taskman.Repo.Migrations.InitTasks do
  use Ecto.Migration

  def change do
    create table(:tasks, primary_key: false) do
      add :id, :identity, primary_key: true, start_value: 100, increment: 1
      add :name, :text, null: false
      add :cost, :bigint, null: false
      add :priority, :bigint, null: false
      add :time_posted, :bigint, null: false # time in seconds!
      add :status, :bigint, null: false
      add :user_id, :bigint, null: false

      add :deadline, :bigint, null: true # time in seconds!
      add :description, :text, null: true
    end
    create index(:tasks, [:user_id, :status])

    create table(:comments, primary_key: false) do
      add :comment_id, :identity, primary_key: true, start_value: 100, increment: 1
      add :content, :text, null: false
      add :time_posted_in_seconds, :bigint, null: false
      add :task_id, references(:tasks, on_delete: :delete_all), null: false
    end
    create index(:comments, [:task_id])

    create table(:categories, primary_key: false) do
      add :category_id, :identity, primary_key: true, start_value: 100, increment: 1
      add :category_name, :text, null: false
      add :user_id, :bigint, null: false
    end
    create index(:categories, [:category_name, :user_id])
    create index(:categories, [:category_id, :user_id])

    create table(:tasks_to_categories, primary_key: false) do
      add :relationship_id, :identity, primary_key: true, start_value: 100, increment: 1
      add :task_id, references(:tasks, on_delete: :delete_all), null: false
      add :category_id, references(:categories, column: :category_id, on_delete: :delete_all), null: false
    end
    create index(:tasks_to_categories, [:task_id])
    create index(:tasks_to_categories, [:category_id])
  end
end
