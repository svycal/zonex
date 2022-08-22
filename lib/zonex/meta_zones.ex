defmodule Zonex.MetaZones do
  @moduledoc """
  Meta zone data.
  """

  use GenServer
  import SweetXml
  alias Zonex.MetaZones.Rule

  @type meta_zone :: String.t()

  # Client

  @doc """
  Starts the process.
  """
  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  A mapping of Olson time zone names to meta zone rules.
  """
  @spec time_zone_rules() :: %{Calendar.time_zone() => [Rule.t()]}
  def time_zone_rules do
    GenServer.call(__MODULE__, :time_zone_rules)
  end

  @doc """
  Fetches the meta zone for a time zone at a particular instant.
  """
  @spec get(time_zone :: Calendar.time_zone(), instant :: DateTime.t()) ::
          {:ok, meta_zone()} | {:error, :meta_zone_not_found}
  def get(time_zone, %DateTime{} = instant) do
    case time_zone_rules()[time_zone] do
      [_ | _] = rules -> meta_zone_at(rules, instant)
      _ -> {:error, :meta_zone_not_found}
    end
  end

  defp meta_zone_at(rules, instant) do
    rules
    |> Enum.find(fn rule ->
      DateTime.compare(instant, rule.from) in [:gt, :eq] and
        DateTime.compare(instant, rule.to) in [:lt]
    end)
    |> then(fn
      %Rule{mzone: mzone} -> {:ok, mzone}
      _ -> {:error, :meta_zone_not_found}
    end)
  end

  # Server

  @impl GenServer
  def init(_arg) do
    path = Application.app_dir(:zonex, "priv/metaZones.xml")
    contents = File.read!(path)
    {:ok, %{rules: parse_rules(contents)}}
  end

  @impl GenServer
  def handle_call(:time_zone_rules, _from, state) do
    {:reply, state[:rules], state}
  end

  # Private helpers

  defp parse_rules(contents) do
    contents
    |> parse_xml()
    |> xpath(~x"//supplementalData/metaZones/metazoneInfo/timezone"el,
      name: ~x"./@type"s,
      rules: [
        ~x"./usesMetazone"l,
        mzone: ~x"./@mzone"s,
        from: ~x"./@from"s |> transform_by(&parse_date/1),
        to: ~x"./@to"s |> transform_by(&parse_date/1)
      ]
    )
    |> Enum.map(&{&1[:name], parse_rule_list(&1[:rules])})
    |> Map.new()
  end

  defp parse_xml(xml) do
    {:ok, root} = Saxmerl.parse_string(xml, dynamic_atoms: true)
    root
  end

  defp parse_date(""), do: nil

  defp parse_date(value) when is_binary(value) do
    case DateTime.from_iso8601("#{value}:00Z") do
      {:ok, datetime, _} -> datetime
      err -> err
    end
  end

  defp parse_date(_), do: nil

  defp parse_rule_list(data) do
    Enum.map(data, &parse_rule/1)
  end

  defp parse_rule(data) do
    %Rule{
      from: data[:from] || beginning_of_time(),
      to: data[:to] || end_of_time(),
      mzone: data[:mzone]
    }
  end

  defp beginning_of_time do
    ~U[0000-01-01 00:00:00Z]
  end

  defp end_of_time do
    ~U[9999-01-01 00:00:00Z]
  end
end
