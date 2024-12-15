defmodule Taskman.Repo.Migrations.InitTasks do
  use Ecto.Migration

  def change do
    create table(:task, primary_key: false) do
      add :id, :identity, primary_key: true, start_value: 100, increment: 1
      add :name, :text, null: false
      add :cost, :bigint, null: false
      add :priority, :bigint, null: false
      add :description, :text, null: false
      add :time_posted, :bigint, null: false
      add :status, :bigint, null: false
      add :deadline, :bigint, null: true
    end

    create index(:task, [:status])
  end
end
