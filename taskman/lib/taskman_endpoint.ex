defmodule Taskman.Endpoint do
  import Plug.Conn
  import Ecto.Query

  use Plug.Router

  plug :match
  plug :dispatch

  get "show/:status" do
    case Taskman.Status.to_number_from_string(status) do
      :error -> send_resp(conn, 500, "bad status, try 'tracking', 'completed', and 'triaged'")
      {:ok, status_id} ->
        query = from t in Taskman.Tasks, where: t.status == ^status_id
        response = Taskman.Repo.all(query)
        |> Poison.encode
        case response do
          {:ok, resp} -> send_resp(conn, 200, resp)
          _ -> send_resp(conn, 500, "some error")
        end
    end
  end

  post "new" do
    {:ok, data, _conn} = read_body(conn)
    case Poison.decode(data, as: %Taskman.Tasks{}) do
      {:ok, task} ->
        {:ok, from_db} = task
        |> Taskman.Logic.task_from_request()
        |> Taskman.Repo.insert(returning: true)
        |> IO.inspect()

        response = Poison.encode(from_db)
        case response do
          {:ok, resp} -> send_resp(conn, 200, resp)
          _ -> send_resp(conn, 500, "some error")
        end
      error ->
        error |> IO.inspect()
        send_resp(conn, 500, "malformed request")
    end
  end

  put "delete/:task_id" do
    from(t in Taskman.Tasks, where: t.id == ^task_id)
    |> Taskman.Repo.delete_all()
    |> IO.inspect()

    send_resp(conn, 200, "{}")
  end

  put "set/:task_id/:status" do
    case Taskman.Status.to_number_from_string(status) do
      :error -> send_resp(conn, 500, "bad status, try 'tracking', 'completed', and 'triaged'")
      {:ok, status_id} ->
        Taskman.Logic.set_status(task_id, status_id)
        send_resp(conn, 200, "{}")
    end
  end

  match _ do
    send_resp(conn, 404, "bad path")
  end
end
