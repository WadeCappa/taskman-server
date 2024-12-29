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
  end
end
