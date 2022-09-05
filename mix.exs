defmodule Zonex.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :zonex,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "Zonex",
      source_url: "https://github.com/svycal/zonex",
      homepage_url: "https://github.com/svycal/zonex",
      docs: docs(),
      description: description(),
      package: package()
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
      {:ex_cldr_time_zone_names, "~> 0.1.0", only: [:test]},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: [
        "README.md",
        "CHANGELOG.md",
        "LICENSE.md"
      ]
    ]
  end

  defp description do
    "A library for compiling enriched time zone information."
  end

  defp package do
    [
      maintainers: ["Derrick Reimer"],
      licenses: ["MIT"],
      links: links()
    ]
  end

  def links do
    %{
      "GitHub" => "https://github.com/svycal/zonex",
      "Changelog" => "https://github.com/svycal/zonex/blob/v#{@version}/CHANGELOG.md",
      "Readme" => "https://github.com/svycal/zonex/blob/v#{@version}/README.md"
    }
  end
end
