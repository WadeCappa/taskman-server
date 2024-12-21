defmodule Taskman.Endpoint do
  import Plug.Conn
  import Ecto.Query, only: [from: 1]

  def init(options) do
    options
  end

  def call(conn, _opts) do
    match(conn.method, conn.path_info, conn)
  end

  defp match("GET", ["show"], conn) do
    query = from Taskman.Tasks
    response = Taskman.Repo.all(query)
    |> Poison.encode
    case response do
      {:ok, resp} -> send_resp(conn, 200, resp)
      _ -> send_resp(conn, 500, "some error")
    end
  end

  defp match("GET", ["describe"], conn) do
    send_resp(conn, 200, "show all information about a task")
  end

  defp match("POST", ["add"], conn) do
    {:ok, data, _conn} = read_body(conn)
    case Poison.decode(data, as: %Taskman.Tasks{}) do
      {:ok, task} ->
        {:ok, from_db} = task
        |> IO.inspect()
        |> Taskman.Logic.task_from_request()
        |> IO.inspect()
        |> Taskman.Repo.insert(returning: true)
        |> IO.inspect()

        response = Poison.encode(from_db)
        |> IO.inspect()
        case response do
          {:ok, resp} -> send_resp(conn, 200, resp)
          _ -> send_resp(conn, 500, "some error")
        end
      error ->
        error |> IO.inspect()
        send_resp(conn, 500, "malformed request")
    end
  end

  defp match("PUT", ["delete"], conn) do
    send_resp(conn, 200, "delete task")
  end

  defp match("PUT", ["complete"], conn) do
    send_resp(conn, 200, "complete task")
  end

  defp match("PUT", ["triage"], conn) do
    send_resp(conn, 200, "triage task")
  end

  defp match("PUT", ["promote"], conn) do
    send_resp(conn, 200, "promote triaged task to task list")
  end

  defp match(_, _, conn) do
    send_resp(conn, 404, "not found")
  end
end
