defmodule Authman.Repo.Migrations.InitDb do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :identity, primary_key: true, start_value: 100, increment: 1, null: false
      add :email, :text, unique: true, null: false
      add :hash, :text, null: false
    end
    create index(:users, [:email, :hash])

    create table(:sessions, primary_key: false) do
      add :id, :identity, unique: true, start_value: 100, increment: 1
      add :token, :text, null: false
      add :user_id, references(:users), primary_key: true, null: false

      add :expire_time, :bigint, null: false
    end
    create index(:sessions, [:token])
    create index(:sessions, [:user_id])
  end
end
