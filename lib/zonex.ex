defmodule Zonex do
  @moduledoc """
  Zonex is a library for compiling enriched time zone information.
  """

  alias Zonex.Aliases
  alias Zonex.Zone
  alias Zonex.MetaZones
  alias Zonex.MetaZones.MetaZone
  alias Zonex.MetaZones.MetaZone.Variants
  alias Zonex.WindowsZones
  alias Zonex.WindowsZones.WindowsZone

  @doc """
  Lists all canonical time zones from the IANA database.

  Since names and UTC offsets vary depending on time of year
  (due to daylight saving time), you need to specify the `instant`
  at which the time zone should be expressed.

  ## Options

  * `:locale` is any locale or locale name validated
    by `Cldr.validate_locale/2`. The default is
    `Cldr.get_locale()` which returns the locale
    set for the current process
  """
  @spec list_canonical(instant :: DateTime.t(), opts :: Keyword.t()) :: [Zone.t()]
  def list_canonical(%DateTime{} = instant, opts \\ []) do
    aliases = Aliases.forward_mapping()

    Tzdata.canonical_zone_list()
    |> Enum.map(&cast(&1, instant, aliases, opts))
  end

  @doc """
  Gets a zone for a given IANA time zone name.

  If the time zone is an alias (not canonical), the canonical zone
  will be returned instead.

  Since names and UTC offsets vary depending on time of year
  (due to daylight saving time), you need to specify the `instant`
  at which the time zone should be expressed.

  ## Options

  * `:locale` is any locale or locale name validated
    by `Cldr.validate_locale/2`. The default is
    `Cldr.get_locale()` which returns the locale
    set for the current process
  """
  @spec get_canonical(zone_name :: String.t(), instant :: DateTime.t(), opts :: Keyword.t()) ::
          {:ok, Zone.t()} | {:error, :zone_not_found}
  def get_canonical(zone_name, %DateTime{} = instant, opts \\ []) do
    if Tzdata.canonical_zone?(zone_name) do
      {:ok, cast(zone_name, instant, Aliases.forward_mapping(), opts)}
    else
      instant
      |> list_canonical()
      |> Enum.find(&(zone_name in &1.aliases))
      |> after_find()
    end
  end

  defp after_find(%Zone{} = zone), do: {:ok, zone}
  defp after_find(_), do: {:error, :zone_not_found}

  @doc """
  Gets a zone for a given IANA time zone name and raises if not found.

  If the time zone is an alias (not canonical), the canonical zone
  will be returned instead.

  Since names and UTC offsets vary depending on time of year
  (due to daylight saving time), you need to specify the `instant`
  at which the time zone should be expressed.

  ## Options

  * `:locale` is any locale or locale name validated
    by `Cldr.validate_locale/2`. The default is
    `Cldr.get_locale()` which returns the locale
    set for the current process
  """
  @spec get_canonical!(zone_name :: String.t(), instant :: DateTime.t(), opts :: Keyword.t()) ::
          Zone.t() | no_return()
  def get_canonical!(zone_name, %DateTime{} = instant, opts \\ []) do
    case get_canonical(zone_name, instant, opts) do
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
  @spec legacy?(zone_name :: Calendar.time_zone()) :: boolean()
  def legacy?(zone_name) do
    # Include legacy time zones, like "EST".
    # Olson time zones (e.g. "America/Chicago") always
    # contain a /, so this is a decent enough proxy.
    !String.contains?(zone_name, "/")
  end

  # Private helpers

  defp cast(name, datetime, aliases, opts) do
    zone = Timex.Timezone.get(name, datetime)
    offset = Timex.Timezone.total_offset(zone)
    formatted_offset = format_offset(offset)
    dst = dst?(name, datetime)
    maybe_meta_zone = build_meta_zone(name, datetime, dst, opts)
    maybe_windows_zone = build_windows_zone(name)
    long_name = build_long_name(name, maybe_meta_zone, maybe_windows_zone)
    generic_long_name = build_generic_long_name(name, maybe_meta_zone, maybe_windows_zone)

    %Zone{
      name: name,
      meta_zone: maybe_meta_zone,
      windows_zone: maybe_windows_zone,
      long_name: long_name,
      generic_long_name: generic_long_name,
      exemplar_city: exemplar_city(maybe_meta_zone),
      abbreviation: zone.abbreviation,
      aliases: Map.get(aliases, name, []),
      zone: zone,
      offset: offset,
      formatted_offset: formatted_offset,
      golden: golden?(name, maybe_meta_zone),
      legacy: legacy?(name),
      dst: dst,
      canonical: true
    }
  end

  defp build_generic_long_name(_, %{long: %{generic: name}}, _)
       when is_binary(name),
       do: name

  defp build_generic_long_name(_, %{long: %{standard: name}}, _)
       when is_binary(name),
       do: name

  defp build_generic_long_name(_, _, %{name: name}) when is_binary(name), do: name
  defp build_generic_long_name(name, _, _), do: name

  defp build_long_name(_, %{long: %{current: name}}, _)
       when is_binary(name),
       do: name

  defp build_long_name(_, %{long: %{generic: name}}, _)
       when is_binary(name),
       do: name

  defp build_long_name(_, _, %{name: name}) when is_binary(name), do: name
  defp build_long_name(name, _, _), do: name

  defp exemplar_city(%{exemplar_city: city}), do: city
  defp exemplar_city(_), do: nil

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

  defp golden?(_, %{territories: territories}), do: "001" in territories
  defp golden?(_, _), do: false

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
