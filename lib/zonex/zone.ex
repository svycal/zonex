defmodule Zonex.Zone do
  @moduledoc """
  An aggregated time zone.
  """

  alias Zonex.MetaZones.MetaZone
  alias Zonex.WindowsZones.WindowsZone

  @enforce_keys [
    :name,
    :meta_zone,
    :windows_zone,
    :long_name,
    :aliases,
    :zone,
    :offset,
    :formatted_offset,
    :abbreviation,
    :listed,
    :legacy,
    :dst,
    :canonical
  ]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          name: Calendar.time_zone(),
          meta_zone: MetaZone.t() | nil,
          windows_zone: WindowsZone.t() | nil,
          long_name: String.t(),
          aliases: [Calendar.time_zone()],
          zone: Timex.TimezoneInfo.t(),
          offset: integer(),
          formatted_offset: String.t(),
          abbreviation: String.t(),
          listed: boolean(),
          legacy: boolean(),
          dst: boolean(),
          canonical: boolean()
        }
end
