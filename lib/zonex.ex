defmodule Zonex do
  @moduledoc """
  Documentation for `Zonex`.
  """

  alias Zonex.WindowsZones
  alias Zonex.Zone

  @standard_names WindowsZones.standard_names()
  @common_names WindowsZones.common_names()

  @doc """
  Lists all time zones.
  """
  @spec list(datetime :: DateTime.t()) :: [Zone.t()]
  def list(%DateTime{} = datetime) do
    Tzdata.canonical_zone_list()
    |> Enum.map(&cast(&1, datetime))
  end

  @doc """
  Gets a zone for a given Olson time zone name.
  """
  @spec get(name :: String.t(), datetime :: DateTime.t()) ::
          {:ok, Zone.t()} | {:error, :zone_not_found}
  def get(name, %DateTime{} = datetime) do
    if Tzdata.canonical_zone?(name) do
      {:ok, cast(name, datetime)}
    else
      datetime
      |> list()
      |> Enum.find(&(name in &1.aliases))
      |> after_find()
    end
  end

  defp after_find(%Zone{} = zone), do: {:ok, zone}
  defp after_find(_), do: {:error, :zone_not_found}

  @doc """
  Gets a zone for a given Olson time zone name and raises if not found.
  """
  @spec get!(name :: String.t(), datetime :: DateTime.t()) ::
          {:ok, Zone.t()} | {:error, :zone_not_found}
  def get!(name, %DateTime{} = datetime) do
    case get(name, datetime) do
      {:ok, zone} -> zone
      _ -> raise "zone not found"
    end
  end

  defp cast(name, datetime) do
    standard_name = @standard_names[name]
    zone = Timex.Timezone.get(name, datetime)
    offset = Timex.Timezone.total_offset(zone)

    %Zone{
      name: name,
      aliases: Map.get(aliases(), name, []),
      standard_name: standard_name,
      common_name: @common_names[standard_name],
      zone: zone,
      offset: offset,
      formatted_offset: "GMT#{format_offset(offset)}",
      listed: listed?(name)
    }
  end

  defp listed?("Etc/" <> _), do: false

  defp listed?(name) do
    Map.has_key?(@standard_names, name)
  end

  defp aliases do
    Tzdata.links()
    |> Enum.group_by(&elem(&1, 1))
    |> Enum.map(&{elem(&1, 0), Enum.map(elem(&1, 1), fn {value, _} -> value end)})
    |> Map.new()
  end

  # Logic borrowed from Timex inspect logic:
  # https://github.com/bitwalker/timex/blob/45424fa293066b210eaf94dd650707343583d085/lib/timezone/inspect.ex#L6
  defp format_offset(total_offset) do
    offset_hours = div(total_offset, 60 * 60)
    offset_mins = div(rem(total_offset, 60 * 60), 60)
    hour = "#{pad_numeric(offset_hours)}"
    min = "#{pad_numeric(abs(offset_mins))}"

    if offset_hours + offset_mins >= 0 do
      "+#{hour}:#{min}"
    else
      "#{hour}:#{min}"
    end
  end

  defp pad_numeric(number) when is_integer(number), do: pad_numeric("#{number}")

  defp pad_numeric(<<?-, number_str::binary>>) do
    res = pad_numeric(number_str)
    <<?-, res::binary>>
  end

  defp pad_numeric(number_str) do
    min_width = 2
    len = String.length(number_str)

    if len < min_width do
      String.duplicate("0", min_width - len) <> number_str
    else
      number_str
    end
  end
end
