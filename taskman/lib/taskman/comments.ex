defmodule Taskman.Comments do
  use Ecto.Schema

  @primary_key false
  @derive {Poison.Encoder, only: [:comment_id, :content, :time_posted_in_seconds]}
  schema "comments" do
    field(:comment_id, :integer)
    field(:content, :string)
    field(:time_posted_in_seconds, :integer)
    field(:task_id, :integer)
  end
end
