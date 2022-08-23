defmodule Zonex.MetaZones do
  @moduledoc """
  Meta zone data.
  """

  use GenServer
  import SweetXml
  alias Zonex.MetaZones.Rule

  @type meta_zone_name :: String.t()
  @type territory :: String.t()

  @doc """
  Lists the rules for a given time zone.
  """
  @spec rules_for_zone(zone_name :: Calendar.time_zone()) :: [Rule.t()]
  def rules_for_zone("Etc/UTC") do
    [
      %Rule{
        from: beginning_of_time(),
        to: end_of_time(),
        mzone: "GMT"
      }
    ]
  end

  def rules_for_zone(zone_name) do
    rules()[zone_name] || []
  end

  @doc """
  Resolves the correct meta zone name at a particular instant.
  """
  @spec resolve(rules :: [Rule.t()], instant :: DateTime.t()) ::
          {:ok, meta_zone_name()} | {:error, term()}
  def resolve([_ | _] = rules, %DateTime{} = instant) do
    rules
    |> Enum.find(&between?(&1, instant))
    |> then(fn
      %Rule{mzone: mzone} -> {:ok, mzone}
      _ -> {:error, :meta_zone_not_found}
    end)
  end

  def resolve(_, _), do: {:error, :meta_zone_not_found}

  @doc """
  Gets the territory for a time zone.
  """
  @spec territories(zone_name :: Calendar.time_zone()) :: [territory()]
  def territories(zone_name) do
    territories_map()[zone_name] || []
  end

  # Client

  @doc """
  Starts the process.
  """
  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Server

  @impl GenServer
  def init(_arg) do
    path = Application.app_dir(:zonex, "priv/metaZones.xml")
    contents = File.read!(path)
    {:ok, %{rules: parse_rules(contents), territories: parse_territories(contents)}}
  end

  @impl GenServer
  def handle_call(:rules, _from, state) do
    {:reply, state[:rules], state}
  end

  @impl GenServer
  def handle_call(:territories, _from, state) do
    {:reply, state[:territories], state}
  end

  # Private helpers

  defp rules do
    GenServer.call(__MODULE__, :rules)
  end

  defp territories_map do
    GenServer.call(__MODULE__, :territories)
  end

  defp parse_rules(xml) do
    xml
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

  defp parse_territories(xml) do
    xml
    |> parse_xml()
    |> xpath(~x"//supplementalData/metaZones/mapTimezones/mapZone"el,
      type: ~x"./@type"s,
      territory: ~x"./@territory"s
    )
    |> Enum.reduce(%{}, fn %{type: type, territory: territory}, acc ->
      territories = Map.get(acc, type, [])

      if territory in territories do
        acc
      else
        Map.put(acc, type, [territory | territories])
      end
    end)
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

  defp between?(rule, instant) do
    DateTime.compare(instant, rule.from) in [:gt, :eq] and
      DateTime.compare(instant, rule.to) in [:lt]
  end
end
