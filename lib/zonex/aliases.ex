defmodule Zonex.Aliases do
  @moduledoc """
  Helpers for time zone aliases.
  """

  @doc """
  A mapping of canonical zone names to aliases.

  This is the reverse of `Tzdata.links/0`.
  """
  @spec forward_mapping() :: %{Calendar.time_zone() => [Calendar.time_zone()]}
  def forward_mapping do
    Tzdata.links()
    |> Enum.filter(&(!Zonex.legacy?(elem(&1, 0))))
    |> Enum.group_by(&elem(&1, 1))
    |> Enum.map(&{elem(&1, 0), Enum.map(elem(&1, 1), fn {value, _} -> value end)})
    |> Map.new()
  end
end
