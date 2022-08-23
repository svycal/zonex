defmodule Zonex.MetaZones.MetaZone do
  @moduledoc """
  Meta zone properties.
  """

  alias Zonex.MetaZones

  defstruct [:name, :territories, :long, :short, :exemplar_city]

  defmodule Variants do
    @moduledoc """
    Meta zone name variants.
    """

    defstruct [:generic, :daylight, :standard, :current]

    @type t :: %__MODULE__{
            generic: String.t() | nil,
            daylight: String.t() | nil,
            standard: String.t() | nil,
            current: String.t() | nil
          }
  end

  @type t :: %__MODULE__{
          name: MetaZones.meta_zone(),
          territories: [MetaZones.territory()],
          long: Variants.t() | nil,
          short: Variants.t() | nil,
          exemplar_city: String.t() | nil
        }
end
