import Config

config :authman, ecto_repos: [Authman.Repo]

config :authman, Authman.Repo,
  database: "authman_repo",
  username: "postgres",
  password: "pass",
  hostname: "db",
  log: :info
