defmodule Zonex.Zone do
  @moduledoc """
  An aggregated time zone.
  """

  @enforce_keys [
    :name,
    :aliases,
    :standard_name,
    :common_name,
    :zone,
    :offset,
    :formatted_offset,
    :listed
  ]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          name: Calendar.time_zone(),
          aliases: [Calendar.time_zone()],
          standard_name: String.t() | nil,
          common_name: String.t() | nil,
          zone: Timex.TimezoneInfo.t() | Timex.AmbiguousTimezoneInfo.t(),
          offset: integer(),
          formatted_offset: String.t(),
          listed: boolean()
        }
end
