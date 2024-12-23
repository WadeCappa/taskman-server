defmodule Authman.Sessions do
  use Ecto.Schema

  @derive {Poison.Encoder, only: [:token]}
  schema "sessions" do
    field(:token, :string)
    field(:user_id, :integer)
    field(:expire_time, :integer)
  end
end
