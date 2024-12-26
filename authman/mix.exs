defmodule Authman.MixProject do
  use Mix.Project

  def project do
    [
      app: :authman,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug_cowboy],
      mod: {Authman.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.16.1"},
      {:plug_cowboy, "~> 2.7.2"},
      {:ecto_sql, "~> 3.12"},
      {:postgrex, "~> 0.19.3"},
      {:poison, "~> 3.1.0"},
      {:bcrypt_elixir, "~> 3.2.0"}
    ]
  end
end
