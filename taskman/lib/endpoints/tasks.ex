defmodule Taskman.Endpoints.Tasks do

  import Plug.Conn

  def get_task(conn, task_id) do
    task =
      task_id
      |> Taskman.Stores.Tasks.get_task_by_id(conn.assigns[:user_id])
      |> Poison.encode()

    case task do
      {:ok, resp} -> send_resp(conn, 200, resp)
      _ -> send_resp(conn, 500, "{}")
    end
  end

  def get_tasks(conn, status, category) do
    case Taskman.Logic.Status.to_number_from_string(status) do
      :error ->
        send_resp(conn, 400, "bad status, try 'tracking', 'completed', and 'triaged'")

      {:ok, status_id} ->
        response =
          Taskman.Stores.Tasks.get_tasks(status_id, conn.assigns[:user_id], category)
          |> Poison.encode()

        case response do
          {:ok, resp} -> send_resp(conn, 200, resp)
          _ -> send_resp(conn, 500, "{}")
        end
    end
  end

  defp get_required_fields(%{"name" => name, "cost" => cost, "priority" => priority}) do
    {:ok,
     %Taskman.Tasks{
       name: name,
       cost: cost,
       priority: priority
     }}
  end

  defp get_required_fields(_malformed_request) do
    {:error, "missing required feilds!"}
  end

  defp task_from_request(request, user_id) do
    case get_required_fields(request) do
      {:ok, new_task} ->
        new_task
        |> Map.put(:time_posted, System.os_time(:second))
        |> Map.put(:status, 0)
        |> Map.put(:user_id, user_id)

      error ->
        error
    end
  end

  def create_task(conn) do
    {:ok, data, conn} = read_body(conn)

    case Poison.decode(data) do
      {:ok, task} ->
        category_ids = Map.get(task, "categories", [])

        {:ok, from_db} = task
          |> task_from_request(conn.assigns[:user_id])
          |> Taskman.Stores.Tasks.insert_task(conn.assigns[:user_id], category_ids)

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

  def delete_task(conn, task_id) do
    Taskman.Stores.Tasks.delete_task_by_id(task_id, conn.assigns[:user_id])
    send_resp(conn, 200, "{}")
  end

  def set_status(conn, task_id, status) do
    case Taskman.Logic.Status.to_number_from_string(status) do
      :error ->
        send_resp(conn, 400, "bad status, try 'tracking', 'completed', and 'triaged'")

      {:ok, status_id} ->
        Taskman.Stores.Tasks.set_status(task_id, status_id, conn.assigns[:user_id])
        send_resp(conn, 200, "{}")
    end
  end

end