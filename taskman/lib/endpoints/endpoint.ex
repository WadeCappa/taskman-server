defmodule Taskman.Endpoint do
  import Plug.Conn

  use Plug.Router

  plug(:match)
  plug(Taskman.Auth)
  plug(:dispatch)

  get "category" do
    Taskman.Endpoints.Categories.get_category(conn)
  end

  post "category" do
    Taskman.Endpoints.Categories.create_category(conn)
  end

  post "comment/:task_id" do
    Taskman.Endpoints.Comments.create_comment(conn, task_id)
  end

  get "describe/:task_id" do
    Taskman.Endpoints.Tasks.get_task(conn, task_id)
  end

  # TODO: Add support for either id or name for the category variable
  get "show/:status/:category" do
    Taskman.Endpoints.Tasks.get_tasks(conn, status, category)
  end

  get "show/:status" do
    Taskman.Endpoints.Tasks.get_tasks(conn, status, :all)
  end

  post "new" do
    Taskman.Endpoints.Tasks.create_task(conn)
  end

  put "delete/:task_id" do
    Taskman.Endpoints.Tasks.delete_task(conn, task_id)
  end

  put "set/:task_id/:status" do
    Taskman.Endpoints.Tasks.set_status(conn, task_id, status)
  end

  match _ do
    send_resp(conn, 404, "{}")
  end
end
