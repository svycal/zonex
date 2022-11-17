# Zonex [![Hex Docs](https://img.shields.io/hexpm/v/zonex)](https://hexdocs.pm/zonex/readme.html)

An Elixir library for compiling enriched time zone information.

## Installation

Add `zonex` to your list of dependencies in `mix.exs`. You will also need to install and configure the `ex_cldr` library with the `ex_cldr_time_zone_names` plugin, since Zonex requires a CLDR backend for compiling time zone names.

```elixir
def deps do
  [
    {:zonex, "~> 0.4.0"},

    # Additional required dependencies
    {:ex_cldr, "~> 2.33"},
    {:ex_cldr_time_zone_names, "~> 0.1"},

    # ...
  ]
end
```

In your application, configure your CLDR backend module:

```elixir
defmodule MyApp.Cldr do
  use Cldr,
    providers: [
      Cldr.TimeZoneNames,
      # ...
    ],
    # ...
end
```

Then, let Zonex know what CLDR backend module to use in your application config:

```elixir
# config/config.exs

config :zonex, cldr_backend: MyApp.Cldr
```
