defmodule Zonex.Zone do
  @moduledoc """
  An aggregated time zone.
  """

  alias Zonex.MetaZones

  @enforce_keys [
    :name,
    :meta_zone,
    :aliases,
    :generic_long_name,
    :windows_name,
    :zone,
    :offset,
    :formatted_offset,
    :abbreviation,
    :listed,
    :legacy
  ]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          name: Calendar.time_zone(),
          meta_zone: MetaZones.meta_zone(),
          aliases: [Calendar.time_zone()],
          generic_long_name: String.t() | nil,
          windows_name: String.t() | nil,
          zone: Timex.TimezoneInfo.t(),
          offset: integer(),
          formatted_offset: String.t(),
          abbreviation: String.t(),
          listed: boolean(),
          legacy: boolean()
        }
end
