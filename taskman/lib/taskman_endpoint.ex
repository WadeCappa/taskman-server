defmodule Taskman.Endpoint do
  import Plug.Conn

  use Plug.Router

  plug(:match)
  plug(Taskman.Auth)
  plug(:dispatch)

  get "describe/:task_id" do
    task = task_id
    |> Taskman.Logic.get_task_by_id(conn.assigns[:user_id])
    |> Poison.encode()

    case task do
      {:ok, resp} -> send_resp(conn, 200, resp)
      _ -> send_resp(conn, 500, "some error")
    end
  end

  get "show/:status" do
    case Taskman.Status.to_number_from_string(status) do
      :error ->
        send_resp(conn, 500, "bad status, try 'tracking', 'completed', and 'triaged'")

      {:ok, status_id} ->
        response =
          Taskman.Logic.get_tasks(status_id, conn.assigns[:user_id])
          |> Taskman.Logic.sort_tasks()
          |> Poison.encode()

        case response do
          {:ok, resp} -> send_resp(conn, 200, resp)
          _ -> send_resp(conn, 500, "some error")
        end
    end
  end

  post "new" do
    {:ok, data, conn} = read_body(conn)
    case Poison.decode(data, as: %Taskman.Tasks{}) do
      {:ok, task} ->
        {:ok, from_db} =
          task
          |> Taskman.Logic.insert_task(conn.assigns[:user_id])

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
    Taskman.Logic.delete_task_by_id(task_id, conn.assigns[:user_id])
    send_resp(conn, 200, "{}")
  end

  put "set/:task_id/:status" do
    case Taskman.Status.to_number_from_string(status) do
      :error ->
        send_resp(conn, 500, "bad status, try 'tracking', 'completed', and 'triaged'")

      {:ok, status_id} ->
        Taskman.Logic.set_status(task_id, status_id, conn.assigns[:user_id])
        send_resp(conn, 200, "{}")
    end
  end

  match _ do
    send_resp(conn, 404, "{}")
  end
end
