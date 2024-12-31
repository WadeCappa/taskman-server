defmodule Taskman.Repo.Migrations.AddCommentsForTasks do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :comment_id, :identity, primary_key: true, start_value: 100, increment: 1
      add :content, :text, null: false
      add :time_posted_in_seconds, :bigint, null: false
      add :task_id, references(:tasks, on_delete: :delete_all), null: false
    end
    create index(:comments, [:task_id])
  end
end
