defmodule Zonex do
  @moduledoc """
  Documentation for `Zonex`.
  """

  alias Zonex.Aliases
  alias Zonex.Zone
  alias Zonex.MetaZones
  alias Zonex.MetaZones.MetaZone
  alias Zonex.MetaZones.MetaZone.Variants
  alias Zonex.WindowsZones
  alias Zonex.WindowsZones.WindowsZone

  @doc """
  Lists all time zones.
  """
  @spec list(datetime :: DateTime.t(), opts :: Keyword.t()) :: [Zone.t()]
  def list(%DateTime{} = datetime, opts \\ []) do
    aliases = Aliases.forward_mapping()

    Tzdata.canonical_zone_list()
    |> Enum.map(&cast(&1, datetime, aliases, opts))
  end

  @doc """
  Gets a zone for a given Olson time zone name.
  """
  @spec get(name :: String.t(), datetime :: DateTime.t(), opts :: Keyword.t()) ::
          {:ok, Zone.t()} | {:error, :zone_not_found}
  def get(name, %DateTime{} = datetime, opts \\ []) do
    if Tzdata.canonical_zone?(name) do
      {:ok, cast(name, datetime, Aliases.forward_mapping(), opts)}
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
  @spec get!(name :: String.t(), datetime :: DateTime.t(), opts :: Keyword.t()) ::
          Zone.t() | no_return()
  def get!(name, %DateTime{} = datetime, opts \\ []) do
    case get(name, datetime, opts) do
      {:ok, zone} -> zone
      _ -> raise "zone not found"
    end
  end

  @doc """
  Determines if a zone name is legacy.

      iex> Zonex.legacy?("America/Chicago")
      false

      iex> Zonex.legacy?("WET")
      true
  """
  @spec legacy?(Calendar.time_zone()) :: boolean()
  def legacy?(name) do
    # Include legacy time zones, like "EST".
    # Olson time zones (e.g. "America/Chicago") always
    # contain a /, so this is a decent enough proxy.
    !String.contains?(name, "/")
  end

  defp cast(name, datetime, aliases, opts) do
    zone = Timex.Timezone.get(name, datetime)
    offset = Timex.Timezone.total_offset(zone)
    formatted_offset = "GMT#{format_offset(offset)}"
    dst = dst?(name, datetime)
    maybe_meta_zone = build_meta_zone(name, datetime, dst, opts)
    maybe_windows_zone = build_windows_zone(name)

    %Zone{
      name: name,
      meta_zone: maybe_meta_zone,
      windows_zone: maybe_windows_zone,
      long_name: build_long_name(name, maybe_meta_zone, maybe_windows_zone),
      abbreviation: zone.abbreviation,
      aliases: Map.get(aliases, name, []),
      zone: zone,
      offset: offset,
      formatted_offset: formatted_offset,
      listed: listed?(name, maybe_meta_zone),
      legacy: legacy?(name),
      dst: dst,
      canonical: true
    }
  end

  defp build_long_name(_, %{long: %{current: value}}, _), do: value
  defp build_long_name(_, %{long: %{generic: value}}, _), do: value
  defp build_long_name(_, _, %{name: value}), do: value
  defp build_long_name(name, _, _), do: name

  defp dst?(zone_name, datetime) do
    time_point = elem(DateTime.to_gregorian_seconds(datetime), 0)

    case Tzdata.periods_for_time(zone_name, time_point, :utc) do
      [period | _] -> period[:std_off] != 0
      _ -> false
    end
  end

  defp build_windows_zone(zone_name) do
    if name = WindowsZones.standard_name(zone_name) do
      %WindowsZone{name: name}
    else
      nil
    end
  end

  defp build_meta_zone(zone_name, datetime, dst, opts) do
    rules = MetaZones.rules_for_zone(zone_name)

    with {:ok, mzone} <- MetaZones.resolve(rules, datetime),
         {:ok, info} <- name_info(zone_name, mzone, opts) do
      %MetaZone{
        name: mzone,
        territories: MetaZones.territories(zone_name),
        long: build_name_variants(info.long, dst),
        short: build_name_variants(info.short, dst),
        exemplar_city: info.exemplar_city
      }
    else
      _ -> nil
    end
  end

  defp build_name_variants(%_{} = data, dst) do
    %Variants{
      generic: data.generic,
      standard: data.standard,
      daylight: data.daylight,
      current: current_name(data, dst)
    }
  end

  defp build_name_variants(_, _), do: nil

  defp name_info(zone_name, mzone, opts) do
    tz_name_backend().resolve(zone_name, String.downcase(mzone), opts)
  end

  defp current_name(%{daylight: daylight}, true) when is_binary(daylight), do: daylight
  defp current_name(%{standard: standard}, false) when is_binary(standard), do: standard
  defp current_name(%{generic: generic}, _), do: generic

  defp listed?("Etc/" <> _, _), do: false

  defp listed?(name, %{long: %{generic: generic}}) when is_binary(generic) do
    !legacy?(name)
  end

  defp listed?(_, _), do: false

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

  defp cldr_backend do
    Application.fetch_env!(:zonex, :cldr_backend)
  end

  defp tz_name_backend do
    Module.concat(cldr_backend(), TimeZoneName)
  end
end
