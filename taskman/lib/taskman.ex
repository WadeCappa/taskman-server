defmodule Taskman do
  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Taskman.Endpoint,
        options: [port: 4001]
      )
    ]

    opts = [strategy: :one_for_one, name: Taskman.Supervisor]
    Supervisor.start_link(children, opts)
  end
end