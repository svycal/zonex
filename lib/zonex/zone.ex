defmodule Zonex.Zone do
  @moduledoc """
  An aggregated time zone.
  """

  @enforce_keys [
    :name,
    :aliases,
    :standard_name,
    :common_name,
    :friendly_name,
    :friendly_name_with_offset,
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
          aliases: [Calendar.time_zone()],
          standard_name: String.t() | nil,
          common_name: String.t() | nil,
          friendly_name: String.t(),
          friendly_name_with_offset: String.t(),
          zone: Timex.TimezoneInfo.t(),
          offset: integer(),
          formatted_offset: String.t(),
          abbreviation: String.t(),
          listed: boolean(),
          legacy: boolean()
        }
end
