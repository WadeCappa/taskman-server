defmodule Taskman.Tasks do
  use Ecto.Schema

  @derive {Poison.Encoder,
           only: [
             :id,
             :name,
             :cost,
             :priority,
             :score,
             :description,
             :time_posted,
             :deadline,
             :status,
             :comments,
             :categories
           ]}
  schema "tasks" do
    field(:name, :string)
    field(:cost, :integer)
    field(:priority, :integer)
    field(:description, :string)
    field(:time_posted, :integer)
    field(:status, :integer)
    field(:deadline, :integer)
    field(:user_id, :integer)
  end
end
