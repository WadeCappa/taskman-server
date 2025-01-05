defmodule Taskman.Auth do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    %{req_headers: headers} = conn

    auth_header =
      headers
      |> IO.inspect()
      |> Enum.filter(fn {key, _value} -> key == "authorization" end)
      |> Enum.reduce({}, fn v, _acc -> v end)
      |> IO.inspect()

    if auth_header == {} do
      send_resp(
        conn,
        401,
        "{\"error\": {\"reason\": \"Auth header not provided, user format 'Authorization: Bearer <token>'\"}}"
      )
      |> halt
    else
      {:ok, resp} = HTTPoison.put("localhost:4002/check", "", [auth_header])

      if Integer.floor_div(Map.get(resp, :status_code, 500), 100) == 2 and
           Map.has_key?(resp, :body) do
        case parse_auth_response(Map.get(resp, :body)) do
          {:ok, user_id} ->
            assign(conn, :user_id, user_id)

          error ->
            IO.inspect(error)

            send_resp(conn, 401, "{\"error\": {\"reason\": \"Invalid user token\"}}")
            |> halt
        end
      else
        IO.inspect(resp)

        send_resp(
          conn,
          401,
          "{\"error\": {\"reason\": \"Invalid user token\"}}"
        )
        |> halt
      end
    end
  end

  defp parse_auth_response(body) do
    case Poison.decode(body, %{keys: :atoms}) do
      {:ok, resp} ->
        if Map.has_key?(resp, :user_id) do
          {:ok, Map.get(resp, :user_id)}
        else
          resp |> IO.inspect()
          {:error, "no user id in response"}
        end

      error ->
        IO.inspect(error)
    end
  end
end
