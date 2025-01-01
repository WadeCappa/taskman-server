defmodule Taskman.Categories do
  use Ecto.Schema

  @primary_key false
  @derive {Poison.Encoder, only: [:category_name, :category_id]}
  schema "categories" do
    field(:category_id, :integer)
    field(:category_name, :string)
    field(:user_id, :integer)
  end
end
