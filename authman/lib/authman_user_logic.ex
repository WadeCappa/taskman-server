defmodule Authman.User.Logic do
  import Ecto.Query

  def exists(email) do
    user = from(u in Authman.Users, where: u.email == ^email)
    |> Authman.Repo.one()
    user != nil
  end

  def create_user(email, password) do
    if exists(email) do
      :error
    else
      Authman.Repo.insert(%Authman.Users{
        email: email,
        hash: Bcrypt.hash_pwd_salt(password)
      }, returning: true)
    end
  end
end
