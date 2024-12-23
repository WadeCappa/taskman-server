defmodule Authman.Session.Logic do
  import Ecto.Query

  defp has_expired(session) do
    session.expire_time > System.os_time()
  end

  def check(token) do
    session = from(s in Authman.Sessions, where: s.token == ^token)
    |> Authman.Repo.one()
    if session != nil and not has_expired(session) do
      {:ok, session.user_id}
    else
      :expired
    end
  end

  def get_session(user) do
    session = from(s in Authman.Sessions, where: s.user_id == ^user.id)
    |> Authman.Repo.one()
    if session != nil and not has_expired(session) do
      session
    else
      # Expire in 24 hours
      new_expire = System.os_time(:second) + (24 * 60 * 60);
      new_token = :crypto.strong_rand_bytes(32) |> Base.url_encode64

      {:ok, session} = Authman.Repo.insert(%Authman.Sessions{
        expire_time: new_expire,
        token: new_token,
        user_id: user.id
      },
      on_conflict: [set: [expire_time: new_expire, token: new_token]],
      conflict_target: [:user_id],
      returning: true)

      session
    end
  end
end
