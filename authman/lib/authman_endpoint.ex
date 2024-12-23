
defmodule Authman.Endpoint do
  import Plug.Conn
  import Ecto.Query
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  post "new" do
    {:ok, data, _conn} = read_body(conn)
    case Poison.decode(data, %{keys: :atoms}) do
      {:ok, %{email: email, password: password}} ->
        {:ok, user} =
          Authman.Repo.insert(%Authman.Users{
            email: email,
            hash: Bcrypt.hash_pwd_salt(password)
          }, returning: true)
        send_resp(conn, 200, "{\"email\": \"#{user.email}\"}")
      error ->
        error |> IO.inspect()
        send_resp(conn, 400, "{}")
    end
  end

  post "login" do
    {:ok, data, _conn} = read_body(conn)
    case Poison.decode(data, %{keys: :atoms}) do
      {:ok, %{email: email, password: password}} ->
        user = from(
          u in Authman.Users,
          where: u.email == ^email)
        |> Authman.Repo.one()
        if user != nil and Bcrypt.verify_pass(password, user.hash) do
          send_resp(conn, 200, Poison.encode!(user))
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
