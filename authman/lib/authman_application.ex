defmodule Authman.Application do
  def start(_type, _args) do
    children = [
      Authman.Repo,
      {Plug.Cowboy, scheme: :http, plug: Authman.Endpoint, options: [port: 4002]},
      {Plug.Cowboy, scheme: :http, plug: Authman.HealthCheck, options: [port: 5501]}
    ]

    opts = [strategy: :one_for_one, name: Authman.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
