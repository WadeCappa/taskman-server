defmodule Taskman.Tasks do
  use Ecto.Schema

  @derive {Poison.Encoder, only: [:foo, :bar, :baz]}
  schema "tasks" do
    field :name, :string
    field :cost, :integer
    field :priority, :integer
    field :description, :string
    field :time_posted, :integer
    field :status, :integer
    field :deadline, :integer
  end
end
