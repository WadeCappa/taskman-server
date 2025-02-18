defmodule Taskman.Application do
  def start(_type, _args) do
    children = [
      Taskman.Repo,
      {Plug.Cowboy, scheme: :http, plug: Taskman.Endpoint, options: [port: 4001]},
      {Plug.Cowboy, scheme: :http, plug: HealthCheck, options: [port: 5501]}
    ]

    opts = [strategy: :one_for_one, name: Taskman.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
