defmodule Authman.Endpoint do
  import Plug.Conn
  import Ecto.Query
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  put "check" do
    {:ok, _data, conn} = read_body(conn)
    %{req_headers: headers} = conn

    case Authman.Session.Logic.extract_auth(headers) do
      {:ok, token} ->
        case Authman.Session.Logic.check(token) do
          {:ok, user_id} ->
            send_resp(conn, 200, "{\"user_id\": #{user_id}}")

          error ->
            error |> IO.inspect()
            send_resp(conn, 400, "{}")
        end

      :error ->
        send_resp(conn, 400, "{}")
    end
  end

  post "new" do
    {:ok, data, _conn} = read_body(conn)

    case Poison.decode(data, %{keys: :atoms}) do
      {:ok, %{email: email, password: password}} ->
        case Authman.User.Logic.create_user(email, password) do
          {:ok, user} ->
            send_resp(conn, 200, "{\"email\": \"#{user.email}\"}")

          :error ->
            send_resp(conn, 400, "{}")
        end

      error ->
        IO.inspect(error)
        send_resp(conn, 400, "{}")
    end
  end

  post "login" do
    {:ok, data, _conn} = read_body(conn)

    case Poison.decode(data, %{keys: :atoms}) do
      {:ok, %{email: email, password: password}} ->
        user =
          from(
            u in Authman.Users,
            where: u.email == ^email
          )
          |> Authman.Repo.one()

        if not is_nil(user) and Bcrypt.verify_pass(password, user.hash) do
          new_session = Authman.Session.Logic.get_session(user)
          send_resp(conn, 200, Poison.encode!(new_session))
        else
          send_resp(conn, 400, "{}")
        end

      error ->
        error |> IO.inspect()
        send_resp(conn, 400, "{}")
    end
  end

  match _ do
    send_resp(conn, 404, "{}")
  end
end
