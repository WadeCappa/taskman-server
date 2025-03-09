defmodule Authman.Session.Logic do
  import Ecto.Query

  defp has_expired(session) do
    System.os_time(:second) > session.expire_time
  end

  def extract_auth(headers) do
    # kinda gross, but we want one value here. If there are multiple auths
    #   take the last one
    bearer_substring = "Bearer "

    header =
      headers
      |> Enum.filter(fn {key, _value} -> key == "authorization" end)
      |> Enum.filter(fn {_key, value} -> String.starts_with?(value, bearer_substring) end)
      |> Enum.map(fn {_key, value} -> String.replace_prefix(value, bearer_substring, "") end)
      |> Enum.reduce(:no_token, fn v, _acc -> v end)

    case header do
      :no_token -> :error
      token -> {:ok, token}
    end
  end

  def check(token) do
    session =
      from(s in Authman.Sessions, where: s.token == ^token)
      |> Authman.Repo.one()

    if not is_nil(session) and not has_expired(session) do
      {:ok, session.user_id}
    else
      :expired
    end
  end

  def get_session(user) do
    session =
      from(s in Authman.Sessions, where: s.user_id == ^user.id)
      |> Authman.Repo.one()

    if not is_nil(session) and not has_expired(session) do
      session
    else
      # Expire in 72 hours
      new_expire = System.os_time(:second) + 24 * 60 * 60 * 3
      new_token = :crypto.strong_rand_bytes(128) |> Base.url_encode64()

      {:ok, session} =
        Authman.Repo.insert(
          %Authman.Sessions{
            expire_time: new_expire,
            token: new_token,
            user_id: user.id
          },
          on_conflict: [set: [expire_time: new_expire, token: new_token]],
          conflict_target: [:user_id],
          returning: true
        )

      session
    end
  end
end
