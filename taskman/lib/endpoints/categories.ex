defmodule Taskman.Endpoints.Categories do
  import Plug.Conn

  defp send_categories(categories, conn) do
    case Poison.encode(categories) do
      {:ok, resp} -> send_resp(conn, 200, resp)
      _ -> send_resp(conn, 500, "{}")
    end
  end

  def get_categories(conn, status_string) do
    case Taskman.Logic.Status.to_number_from_string(status_string) do
      {:ok, status_id} ->
        conn.assigns[:user_id]
        |> Taskman.Stores.Categories.get_categories_for_user(status_id)
        |> send_categories(conn)

      error ->
        send_resp(conn, 500, Poison.encode!(error))
    end
  end

  def get_categories(conn) do
    conn.assigns[:user_id]
    |> Taskman.Stores.Categories.get_categories_for_user()
    |> send_categories(conn)
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

      {:error, reason} ->
        send_resp(conn, 400, Poison.encode!(%{error: reason}))

      error ->
        IO.inspect(error)
        send_resp(conn, 400, Poison.encode!(Taskman.Logic.Errors.get_invalid_input_error()))
    end
  end
end
