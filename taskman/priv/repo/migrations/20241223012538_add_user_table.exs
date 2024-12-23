defmodule Taskman.Repo.Migrations.AddUserTable do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :user_id, null: false
    end

    drop index(:tasks, [:status])
    create index(:tasks, [:user_id, :status])
  end
end
