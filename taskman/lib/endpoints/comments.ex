defmodule Taskman.Endpoints.Comments do

  import Plug.Conn

  defp store_comment_internal(comment_text, task_id, user_id) do
    if comment_text == :no_comment do
      {:error, %{reason: "cannot post a comment without any content"}}
    else
      Taskman.Stores.Comments.new_comment(comment_text, task_id, user_id)
    end
  end

  def create_comment(conn, task_id) do
    {:ok, data, conn} = read_body(conn)

    case Poison.decode(data, as: %{}) do
      {:ok, content} ->
        case store_comment_internal(
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

end
