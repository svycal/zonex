defmodule Zonex do
  @moduledoc """
  Documentation for `Zonex`.
  """

  alias Zonex.Aliases
  alias Zonex.WindowsZones
  alias Zonex.Zone

  @standard_names WindowsZones.standard_names()
  @common_names WindowsZones.common_names()

  @doc """
  Lists all time zones.
  """
  @spec list(datetime :: DateTime.t()) :: [Zone.t()]
  def list(%DateTime{} = datetime) do
    aliases = Aliases.forward_mapping()

    Tzdata.canonical_zone_list()
    |> Enum.map(&cast(&1, datetime, aliases))
  end

  @doc """
  Gets a zone for a given Olson time zone name.
  """
  @spec get(name :: String.t(), datetime :: DateTime.t()) ::
          {:ok, Zone.t()} | {:error, :zone_not_found}
  def get(name, %DateTime{} = datetime) do
    if Tzdata.canonical_zone?(name) do
      {:ok, cast(name, datetime, Aliases.forward_mapping())}
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
  @spec get!(name :: String.t(), datetime :: DateTime.t()) :: Zone.t() | no_return()
  def get!(name, %DateTime{} = datetime) do
    case get(name, datetime) do
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

  @doc """
  Builds a long descriptive label with GMT offset.

      iex> Zonex.long_label(Zonex.get!("America/Chicago", ~U[2022-06-01 00:00:00Z]))
      "(GMT-05:00) Central Time (US & Canada)"

      iex> Zonex.long_label(Zonex.get!("America/Shiprock", ~U[2022-06-01 00:00:00Z]))
      "(GMT-06:00) Mountain Time (US & Canada)"

      iex> Zonex.long_label(Zonex.get!("America/North_Dakota/New_Salem", ~U[2022-06-01 00:00:00Z]))
      "(GMT-05:00) America - North Dakota - New Salem"
  """
  @spec long_label(Zone.t()) :: String.t()
  def long_label(%Zone{formatted_offset: offset} = zone) do
    "(#{offset}) #{friendly_name(zone)}"
  end

  @doc """
  Builds a short descriptive label.

      iex> Zonex.short_label(Zonex.get!("America/Chicago", ~U[2022-06-01 00:00:00Z]))
      "Central Time (US & Canada)"

      iex> Zonex.short_label(Zonex.get!("America/Kentucky/Louisville", ~U[2022-06-01 00:00:00Z]))
      "America - Kentucky - Louisville"
  """
  @spec short_label(Zone.t()) :: String.t()
  def short_label(%Zone{} = zone) do
    friendly_name(zone)
  end

  defp friendly_name(%{common_name: common_name}) when is_binary(common_name) do
    common_name
  end

  defp friendly_name(%{standard_name: standard_name}) when is_binary(standard_name) do
    standard_name
  end

  defp friendly_name(%{name: name}) do
    name
    |> String.replace(~r/\//, " - ", global: true)
    |> String.replace(~r/_/, " ", global: true)
  end

  defp cast(name, datetime, aliases) do
    standard_name = @standard_names[name]
    zone = Timex.Timezone.get(name, datetime)
    offset = Timex.Timezone.total_offset(zone)

    %Zone{
      name: name,
      aliases: Map.get(aliases, name, []),
      standard_name: standard_name,
      common_name: @common_names[standard_name],
      zone: zone,
      offset: offset,
      formatted_offset: "GMT#{format_offset(offset)}",
      listed: listed?(name),
      legacy: legacy?(name)
    }
  end

  defp listed?("Etc/" <> _), do: false

  defp listed?(name) do
    !legacy?(name) && Map.has_key?(@standard_names, name)
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
