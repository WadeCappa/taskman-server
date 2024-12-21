defmodule Taskman.MixProject do
  use Mix.Project

  def project do
    [
      app: :taskman,
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
      mod: {Taskman.Application, []}
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

      {:dialyxir, "~> 1.4.5", only: [:dev], runtime: false}
    ]
  end
end
