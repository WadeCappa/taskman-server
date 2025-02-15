defmodule Taskman.Endpoints.Tasks do
  import Plug.Conn

  def get_task(conn, task_id) do
    task =
      task_id
      |> Taskman.Stores.Tasks.get_task_by_id(conn.assigns[:user_id])

    case task do
      {:ok, resp} -> send_resp(conn, 200, Poison.encode!(resp))
      {:not_found, resp} -> send_resp(conn, 400, Poison.encode!(%{error: resp}))
      _ -> send_resp(conn, 500, "{}")
    end
  end

  defp category_name_to_list(:all, _user_id) do
    {:ok, []}
  end

  # TODO: we should probably return an error instead of a result. Also, we should
  # be able to handle multiple categories if we want
  defp category_name_to_list(category_name, user_id) do
    case Taskman.Stores.Categories.get_category_id(category_name, user_id) do
      {:not_found, _resp} ->
        {:error, %{reason: "could not find category name", category_name: category_name}}

      {:ok, c_id} ->
        {:ok, [c_id]}
    end
  end

  def get_tasks(conn, status, category_name) do
    case Taskman.Logic.Status.to_number_from_string(status) do
      {:ok, status_id} ->
        user_id = conn.assigns[:user_id]

        case category_name_to_list(category_name, user_id) do
          {:ok, category_ids} ->
            response =
              Taskman.Stores.Tasks.get_tasks(status_id, user_id, category_ids)
              |> Taskman.Logic.Sort.sort_tasks(Taskman.Logic.Status.get_name(status_id))
              |> Poison.encode()

            case response do
              {:ok, resp} -> send_resp(conn, 200, resp)
              _ -> send_resp(conn, 500, "{}")
            end

          {:error, error} ->
            send_resp(conn, 400, Poison.encode!(%{error: error}))
        end

      error ->
        send_resp(conn, 400, Poison.encode!(error))
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

  defp get_required_fields(malformed_request) do
    {:error, %{reason: "missing required feilds!", malformed_request: malformed_request}}
  end

  defp task_from_request(request, user_id) do
    case get_required_fields(request) do
      {:ok, new_task} ->
        {:ok,
         new_task
         |> Map.put(:time_posted, System.os_time(:second))
         |> Map.put(:status, 0)
         |> Map.put(:user_id, user_id)}

      error ->
        error
    end
  end

  def create_task(conn) do
    {:ok, data, conn} = read_body(conn)

    case Poison.decode(data) do
      {:ok, task} ->
        category_ids = Map.get(task, "categories", [])

        case task_from_request(task, conn.assigns[:user_id]) do
          {:ok, task_from_request} ->
            case Taskman.Stores.Tasks.insert_task(task_from_request, category_ids) do
              {:ok, from_db} ->
                send_resp(conn, 200, Poison.encode!(from_db))

              {:error, error} ->
                send_resp(conn, 400, Poison.encode!(%{error: error}))
            end

          {:error, error} ->
            send_resp(conn, 400, Poison.encode!(%{error: error}))

          error ->
            IO.inspect(error)
            send_resp(conn, 500, "{}")
        end

      error ->
        IO.inspect(error)
        send_resp(conn, 400, Poison.encode!(Taskman.Logic.Errors.get_invalid_input_error()))
    end
  end

  def delete_task(conn, task_id) do
    Taskman.Stores.Tasks.delete_task_by_id(task_id, conn.assigns[:user_id])
    send_resp(conn, 200, "{}")
  end

  def set_status(conn, task_id, status) do
    case Taskman.Logic.Status.to_number_from_string(status) do
      {:ok, status_id} ->
        Taskman.Stores.Tasks.set_status(task_id, status_id, conn.assigns[:user_id])
        send_resp(conn, 200, "{}")

      error ->
        send_resp(conn, 400, Poison.encode!(error))
    end
  end
end
