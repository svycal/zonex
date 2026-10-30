defmodule Zonex.DaylightSaving do
  @moduledoc """
  Daylight saving time data.
  """

  use GenServer

  @table __MODULE__

  @doc """
  Determines if a Tzdata period is daylight saving time.
  """
  @spec period?(period :: map()) :: boolean()
  def period?(%{std_off: std_off}), do: std_off != 0

  @doc """
  Determines if a zone observes daylight saving time at any point
  during a calendar year (in UTC).
  """
  @spec observes?(zone_name :: Calendar.time_zone(), year :: integer()) :: boolean()
  def observes?(zone_name, year) do
    key = {zone_name, year, Tzdata.tzdata_version()}

    case :ets.lookup(@table, key) do
      [{^key, observes}] ->
        observes

      [] ->
        observes = during_year?(zone_name, year)
        :ets.insert(@table, {key, observes})
        observes
    end
  end

  # Client

  @doc """
  Starts the process.
  """
  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Server

  # Observance only changes with the year and the Tzdata release, so callers
  # memoize it in a public table, one entry per zone. Including the release in
  # the key keeps automatic Tzdata updates from serving stale results. The
  # process owns the table.
  @impl GenServer
  def init(_arg) do
    :ets.new(@table, [
      :set,
      :public,
      :named_table,
      read_concurrency: true,
      write_concurrency: true
    ])

    {:ok, nil}
  end

  # Private helpers

  # Walks the periods that overlap the year, and checks whether any of them
  # is daylight saving time.
  defp during_year?(zone_name, year) do
    year_start = :calendar.datetime_to_gregorian_seconds({{year, 1, 1}, {0, 0, 0}})
    year_end = :calendar.datetime_to_gregorian_seconds({{year + 1, 1, 1}, {0, 0, 0}})

    between?(zone_name, year_start, year_end)
  end

  defp between?(_zone_name, from, until) when from >= until, do: false

  defp between?(zone_name, from, until) do
    case Tzdata.periods_for_time(zone_name, from, :utc) do
      [period | _] ->
        cond do
          period?(period) -> true
          is_integer(period.until.utc) -> between?(zone_name, period.until.utc, until)
          true -> false
        end

      _ ->
        false
    end
  end
end
