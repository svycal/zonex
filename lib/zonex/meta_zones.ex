defmodule Zonex.MetaZones do
  @moduledoc """
  Meta zone data.
  """

  use GenServer
  import SweetXml
  alias Zonex.MetaZones.Rule

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
  @spec rules() :: %{Calendar.time_zone() => [Rule.t()]}
  def rules do
    GenServer.call(__MODULE__, :rules)
  end

  # Server

  @impl GenServer
  def init(_arg) do
    path = Application.app_dir(:zonex, "priv/metaZones.xml")
    contents = File.read!(path)
    {:ok, parse_contents(contents)}
  end

  @impl GenServer
  def handle_call(:rules, _from, state) do
    {:reply, state, state}
  end

  # Private helpers

  defp parse_contents(contents) do
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
    |> Enum.map(&{&1[:name], parse_rules(&1[:rules])})
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

  defp parse_rules(data) do
    Enum.map(data, &parse_rule/1)
  end

  defp parse_rule(data) do
    %Rule{
      from: data[:from],
      to: data[:to],
      mzone: data[:mzone]
    }
  end
end
