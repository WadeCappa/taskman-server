import Config

config :taskman, ecto_repos: [Taskman.Repo]
config :taskman, Taskman.Repo,
  database: "taskman_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"