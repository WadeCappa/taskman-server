defmodule Taskman.Tasks do
  use Ecto.Schema

  @derive {Poison.Encoder,
           only: [
             :id,
             :name,
             :cost,
             :priority,
             :score,
             :time_posted,
             :time_completed,
             :deadline,
             :status,
             :comments,
             :categories
           ]}
  schema "tasks" do
    field(:name, :string)
    field(:cost, :integer)
    field(:priority, :integer)
    field(:time_completed, :integer)
    field(:time_posted, :integer)
    field(:status, :integer)
    field(:deadline, :integer)
    field(:user_id, :integer)
  end
end
