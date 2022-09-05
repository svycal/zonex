defmodule ZonexTest do
  @moduledoc false

  use ExUnit.Case
  doctest Zonex

  test "includes only canonical zones" do
    Enum.each(all_zones(), fn %{name: name} ->
      assert Tzdata.canonical_zone?(name)
    end)
  end

  test "aliases don't include canonical names" do
    Enum.each(all_zones(), fn %{aliases: aliases} ->
      Enum.each(aliases, fn aliaz ->
        refute Tzdata.canonical_zone?(aliaz)
      end)
    end)
  end

  test "legacy zones aren't standard" do
    refute Zonex.get!("CST6CDT", now()).standard
  end

  test "excludes legacy zones from aliases" do
    refute "Cuba" in Zonex.get!("America/Havana", now()).aliases
  end

  test "flags legacy zones" do
    assert Zonex.get!("EST", now()).legacy
    assert Zonex.get!("CST6CDT", now()).legacy
    refute Zonex.get!("America/Chicago", now()).legacy
  end

  test "uses offset relative to given date" do
    assert Zonex.get!("America/Chicago", ~U[2022-01-01 00:00:00Z]).offset == -21_600
    assert Zonex.get!("America/Chicago", ~U[2022-06-01 00:00:00Z]).offset == -18_000
  end

  test "formats offsets" do
    assert Zonex.get!("America/Chicago", ~U[2022-01-01 00:00:00Z]).formatted_offset == "-06:00"
    assert Zonex.get!("America/Chicago", ~U[2022-06-01 00:00:00Z]).formatted_offset == "-05:00"
  end

  test "includes meta zone info" do
    %{meta_zone: meta_zone} = zone = Zonex.get!("America/Chicago", ~U[2022-01-01 00:00:00Z])
    assert meta_zone.name == "America_Central"
    assert meta_zone.territories == ["001"]
    assert meta_zone.long.generic == "Central Time"
    assert meta_zone.long.standard == "Central Standard Time"
    assert meta_zone.long.daylight == "Central Daylight Time"
    assert meta_zone.long.current == "Central Standard Time"
    assert meta_zone.short.generic == "CT"
    assert meta_zone.short.standard == "CST"
    assert meta_zone.short.daylight == "CDT"
    assert meta_zone.short.current == "CST"
    refute zone.dst

    # In DST...
    zone = Zonex.get!("America/Chicago", ~U[2022-06-01 00:00:00Z])
    assert zone.meta_zone.long.current == "Central Daylight Time"
    assert zone.meta_zone.short.current == "CDT"
    assert zone.dst

    # On the boundary, uses UTC time...
    zone = Zonex.get!("Europe/Copenhagen", ~U[2015-10-25 02:40:00Z])
    assert zone.meta_zone.long.current == "Central European Standard Time"
    refute zone.dst
  end

  test "determines the best long name" do
    # Current meta zone name if available
    zone = Zonex.get!("America/Chicago", ~U[2022-01-01 00:00:00Z])
    assert zone.long_name == "Central Standard Time"
    assert zone.exemplar_city == "Chicago"

    zone = Zonex.get!("Europe/London", ~U[2022-06-01 00:00:00Z])
    assert zone.long_name == "British Summer Time"

    # Olson name if meta zone is not available
    zone = Zonex.get!("America/Argentina/Mendoza", ~U[2022-06-01 00:00:00Z])
    assert zone.long_name == "America/Argentina/Mendoza"

    # Generic name for UTC
    zone = Zonex.get!("Etc/UTC", ~U[2022-01-01 00:00:00Z])
    assert zone.long_name == "Coordinated Universal Time"
  end

  test "accepts a locale option" do
    %{meta_zone: meta_zone} = Zonex.get!("America/Chicago", ~U[2022-01-01 00:00:00Z], locale: :fr)

    assert %{
             long: %{generic: "heure du centre nord-américain"}
           } = meta_zone
  end

  test "includes a parsed zone struct" do
    Enum.each(all_zones(), fn %{zone: zone} ->
      assert %Timex.TimezoneInfo{} = zone
    end)
  end

  test "looks up aliases" do
    # Africa/Djibouti is an alias for Africa/Nairobi
    assert Zonex.get!("Africa/Djibouti", now()) == Zonex.get!("Africa/Nairobi", now())
  end

  test "straddles the DST boundary" do
    name = "Europe/Copenhagen"

    # iex> DateTime.new(~D[2018-10-28], ~T[02:00:00], "Europe/Copenhagen")
    # {:ambiguous, #DateTime<2018-10-28 02:00:00+02:00 CEST Europe/Copenhagen>,
    # #DateTime<2018-10-28 02:00:00+01:00 CET Europe/Copenhagen>}
    before_fallback = ~U[2018-10-28 00:00:00Z]
    during_fallback = ~U[2018-10-28 00:30:00Z]
    after_fallback = ~U[2018-10-28 01:00:00Z]

    assert Zonex.get!(name, before_fallback).formatted_offset == "+02:00"
    assert Zonex.get!(name, during_fallback).formatted_offset == "+02:00"
    assert Zonex.get!(name, after_fallback).formatted_offset == "+01:00"

    # iex> DateTime.new(~D[2022-03-27], ~T[02:00:00], "Europe/Copenhagen")
    # {:gap, #DateTime<2022-03-27 01:59:59.999999+01:00 CET Europe/Copenhagen>,
    # #DateTime<2022-03-27 03:00:00+02:00 CEST Europe/Copenhagen>}
    before_springfwd = ~U[2022-03-27 00:00:00Z]
    during_springfwd = ~U[2022-03-27 00:30:00Z]
    after_springfwd = ~U[2022-03-27 01:00:00Z]

    assert Zonex.get!(name, before_springfwd).formatted_offset == "+01:00"
    assert Zonex.get!(name, during_springfwd).formatted_offset == "+01:00"
    assert Zonex.get!(name, after_springfwd).formatted_offset == "+02:00"
  end

  defp all_zones do
    Zonex.list(now())
  end

  defp now do
    ~U[2022-06-01 00:00:00Z]
  end
end
