defmodule Zonex.WindowsZones.WindowsZone do
  @moduledoc """
  Windows zone properties.
  """

  alias Zonex.WindowsZones

  defstruct [:name]

  @type t :: %__MODULE__{
          name: WindowsZones.standard_name()
        }
end
