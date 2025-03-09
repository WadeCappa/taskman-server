import Config

config :taskman, ecto_repos: [Taskman.Repo]

config :taskman, Taskman.Repo,
  database: System.get_env("DB_TASKMAN_REPO"),
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASS"),
  hostname: System.get_env("DB_HOSTNAME")
