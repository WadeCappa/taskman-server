defmodule Taskman.Endpoint do
  import Plug.Conn

  use Plug.Router

  plug(:match)
  plug(Taskman.Auth)
  plug(:dispatch)

  post "comment/:task_id" do
    {:ok, data, conn} = read_body(conn)

    case Poison.decode(data, as: %{}) do
      {:ok, content} ->
        case Taskman.Logic.new_comment(
               Map.get(content, "content", :no_comment),
               task_id,
               conn.assigns[:user_id]
             ) do
          {:ok, new_comment} ->
            response = Poison.encode(new_comment)

            case response do
              {:ok, resp} -> send_resp(conn, 200, resp)
              _ -> send_resp(conn, 500, "{}")
            end

          error ->
            IO.inspect(error)
            send_resp(conn, 400, "{}")
        end

      error ->
        error |> IO.inspect()
        send_resp(conn, 500, "{}")
    end
  end

  get "describe/:task_id" do
    task =
      task_id
      |> Taskman.Logic.get_task_by_id(conn.assigns[:user_id])
      |> Poison.encode()

    case task do
      {:ok, resp} -> send_resp(conn, 200, resp)
      _ -> send_resp(conn, 500, "{}")
    end
  end

  defp show(conn, status, category) do
    case Taskman.Status.to_number_from_string(status) do
      :error ->
        send_resp(conn, 400, "bad status, try 'tracking', 'completed', and 'triaged'")

      {:ok, status_id} ->
        response =
          Taskman.Logic.get_tasks(status_id, conn.assigns[:user_id], category)
          |> Taskman.Logic.sort_tasks()
          |> Poison.encode()

        case response do
          {:ok, resp} -> send_resp(conn, 200, resp)
          _ -> send_resp(conn, 500, "{}")
        end
    end
  end

  # TODO: Add support for either id or name for the category variable
  get "show/:status/:category" do
    show(conn, status, category)
  end

  get "show/:status" do
    show(conn, status, :all)
  end

  post "new" do
    {:ok, data, conn} = read_body(conn)

    case Poison.decode(data, as: %Taskman.Tasks{}) do
      {:ok, task} ->
        category_ids = Map.get(task, "categories", [])

        {:ok, from_db} =
          Taskman.Logic.insert_task(task, conn.assigns[:user_id], category_ids)

        response = Poison.encode(from_db)

        case response do
          {:ok, resp} -> send_resp(conn, 200, resp)
          _ -> send_resp(conn, 500, "{}")
        end

      error ->
        error |> IO.inspect()
        send_resp(conn, 400, "{}")
    end
  end

  put "delete/:task_id" do
    Taskman.Logic.delete_task_by_id(task_id, conn.assigns[:user_id])
    send_resp(conn, 200, "{}")
  end

  put "set/:task_id/:status" do
    case Taskman.Status.to_number_from_string(status) do
      :error ->
        send_resp(conn, 400, "bad status, try 'tracking', 'completed', and 'triaged'")

      {:ok, status_id} ->
        Taskman.Logic.set_status(task_id, status_id, conn.assigns[:user_id])
        send_resp(conn, 200, "{}")
    end
  end

  match _ do
    send_resp(conn, 404, "{}")
  end
end
