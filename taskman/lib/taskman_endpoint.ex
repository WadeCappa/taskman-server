defmodule Taskman.Endpoint do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    match(conn.method, conn.path_info, conn)
  end

  defp match("GET", ["show"], conn) do
    send_resp(conn, 200, "show all tasks")
  end

  defp match("GET", ["describe"], conn) do
    send_resp(conn, 200, "show all information about a task")
  end

  defp match("POST", ["add"], conn) do
    send_resp(conn, 200, "add new task")
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
