defmodule Zonex.MetaZones.Rule do
  @moduledoc """
  A meta zone rule.
  """

  defstruct [:from, :to, :mzone]

  @type t :: %__MODULE__{
          from: DateTime.t(),
          to: DateTime.t(),
          mzone: String.t()
        }
end
