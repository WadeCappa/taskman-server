defmodule Authman.Repo.Migrations.InitDb do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :identity, unique: true, start_value: 100, increment: 1
      add :email, :text, primary_key: true, null: false
      add :hash, :text, null: false
    end

    create index(:users, [:email, :hash])
  end
end
