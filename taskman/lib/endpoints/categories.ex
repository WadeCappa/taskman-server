defmodule Taskman.Endpoints.Categories do
  import Plug.Conn

  def get_category(conn) do
    categories =
      conn.assigns[:user_id]
      |> Taskman.Stores.Categories.get_categories_for_user()
      |> Poison.encode()

    case categories do
      {:ok, resp} -> send_resp(conn, 200, resp)
      _ -> send_resp(conn, 500, "{}")
    end
  end

  def create_category(conn) do
    {:ok, data, conn} = read_body(conn)

    case Poison.decode(data) do
      {:ok, category_request} ->
        category_name = Map.get(category_request, "name")

        {:ok, from_db} =
          Taskman.Stores.Categories.try_create_category(category_name, conn.assigns[:user_id])

        response = Poison.encode(from_db)

        case response do
          {:ok, resp} -> send_resp(conn, 200, resp)
          _ -> send_resp(conn, 500, "{}")
        end

      error ->
        send_resp(conn, 400, Poison.encode!(error))
    end
  end

  def add_to_category(conn, task_id, category_id) do
    case Taskman.Stores.Tasks.get_task_by_id(task_id, conn.assigns[:user_id]) do
      {:ok, task} ->
        case Taskman.Stores.Categories.insert_category_relations(task, category_id) do
          {:ok, new_task} ->
            send_resp(conn, 200, Poison.encode!(new_task))
        end
      {:not_found, error} ->
        send_resp(conn, 400, Poison.encode!({:not_found, error}))
      error ->
        IO.inspect(error)
        send_resp(conn, 500, "{}")
    end
  end
end
