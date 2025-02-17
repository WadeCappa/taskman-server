defmodule HealthCheck do
  import Plug.Conn
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "check" do
    send_resp(conn, 200, "")
  end
end
