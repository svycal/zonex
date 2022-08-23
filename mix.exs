defmodule Zonex.MixProject do
  use Mix.Project

  def project do
    [
      app: :zonex,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Zonex.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tzdata, "~> 1.1"},
      {:timex, "~> 3.7"},
      {:sweet_xml, "~> 0.6"},
      {:saxmerl, "~> 0.1"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_cldr, "~> 2.33", only: [:test]},
      {:ex_cldr_time_zone_names,
       only: [:test], git: "https://github.com/svycal/cldr_time_zone_names.git", ref: "c49cbe2"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
