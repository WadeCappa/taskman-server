import Config

config :authman, ecto_repos: [Authman.Repo]

config :authman, Authman.Repo,
  database: System.get_env("DB_AUTHMAN_REPO"),
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASS"),
  hostname: System.get_env("DB_HOSTNAME")
