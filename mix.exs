defmodule Zonex.MixProject do
  use Mix.Project

  def project do
    [
      app: :zonex,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tzdata, "~> 1.1"},
      {:timex, "~> 3.7"},
      {:sweet_xml, "~> 0.6"},
      {:saxmerl, "~> 0.1"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end
end
