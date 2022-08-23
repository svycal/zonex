defmodule Zonex.Zone do
  @moduledoc """
  An aggregated time zone.
  """

  alias Zonex.MetaZones

  defmodule Names do
    @moduledoc """
    Various names for time zones.
    """

    defstruct [:generic, :daylight, :standard, :current, :windows]

    @type t :: %__MODULE__{
            generic: String.t() | nil,
            daylight: String.t() | nil,
            standard: String.t() | nil,
            current: String.t() | nil,
            windows: String.t() | nil
          }
  end

  @enforce_keys [
    :name,
    :meta_zone,
    :names,
    :aliases,
    :zone,
    :offset,
    :formatted_offset,
    :abbreviation,
    :listed,
    :legacy,
    :dst
  ]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          name: Calendar.time_zone(),
          meta_zone: MetaZones.meta_zone(),
          aliases: [Calendar.time_zone()],
          names: Names.t(),
          zone: Timex.TimezoneInfo.t(),
          offset: integer(),
          formatted_offset: String.t(),
          abbreviation: String.t(),
          listed: boolean(),
          legacy: boolean(),
          dst: boolean()
        }
end
