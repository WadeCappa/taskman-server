defmodule Authman.Users do
  use Ecto.Schema

  @derive {Poison.Encoder, except: [:__meta__, :hash]}
  schema "users" do
    field(:email, :string)
    field(:hash, :string)
  end
end
