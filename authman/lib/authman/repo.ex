defmodule Authman.Repo do
  use Ecto.Repo,
    otp_app: :authman,
    adapter: Ecto.Adapters.Postgres
end
