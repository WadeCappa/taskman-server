defmodule Taskman.Task do
  use Ecto.Schema

  schema "task" do
    field :name, :string
    field :cost, :integer
    field :priority, :integer
    field :description, :string
    field :time_posted, :integer
    field :status, :integer
    field :deadline, :integer
  end
end
