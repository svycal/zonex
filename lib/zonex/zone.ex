defmodule Zonex.Zone do
  @moduledoc """
  An aggregated time zone.

  The `dst` field is whether daylight saving time is in effect at the
  instant the zone was built for. The `observes_dst` field is whether the
  zone observes daylight saving time at any point during the calendar
  year (in UTC) of that instant. For example, in January, America/Denver
  and America/Phoenix both have `dst: false`, but only America/Denver
  has `observes_dst: true`.
  """

  alias Zonex.MetaZones.MetaZone
  alias Zonex.WindowsZones.WindowsZone

  @enforce_keys [
    :name,
    :meta_zone,
    :windows_zone,
    :long_name,
    :generic_long_name,
    :exemplar_city,
    :aliases,
    :zone,
    :offset,
    :formatted_offset,
    :abbreviation,
    :golden,
    :legacy,
    :dst,
    :observes_dst,
    :canonical
  ]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          name: Calendar.time_zone(),
          meta_zone: MetaZone.t() | nil,
          windows_zone: WindowsZone.t() | nil,
          long_name: String.t(),
          generic_long_name: String.t(),
          exemplar_city: String.t() | nil,
          aliases: [Calendar.time_zone()],
          zone: Timex.TimezoneInfo.t(),
          offset: integer(),
          formatted_offset: String.t(),
          abbreviation: String.t(),
          golden: boolean(),
          legacy: boolean(),
          dst: boolean(),
          observes_dst: boolean(),
          canonical: boolean()
        }
end
