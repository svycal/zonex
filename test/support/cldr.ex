defmodule Zonex.Cldr do
  @moduledoc """
  A CLDR backend for tests.
  """

  require Cldr.TimeZoneName

  use Cldr,
    default_locale: "en",
    locales: ["en", "fr"],
    providers: [Cldr.TimeZoneName]
end
