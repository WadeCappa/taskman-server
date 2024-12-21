defmodule Taskman.Endpoint do
  import Plug.Conn
  import Ecto.Query

  use Plug.Router

  plug :match
  plug :dispatch

  get "show/:status" do
    case Taskman.Status.to_number(status) do
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

  post "add" do
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

  put "complete/:task_id" do
    send_resp(conn, 200, "complete task #{task_id}")
  end

  put "triage/:task_id" do
    send_resp(conn, 200, "triage task #{task_id}")
  end

  put "promote/:task_id" do
    send_resp(conn, 200, "promote triaged task to task list #{task_id}")
  end

  match _ do
    send_resp(conn, 404, "bad path")
  end
end
