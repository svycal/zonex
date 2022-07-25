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

  test "Etc/* zones aren't listed" do
    Enum.each(listed_zones(), fn %{name: name} ->
      refute String.starts_with?(name, "Etc/")
    end)
  end

  test "uses offset relative to given date" do
    assert Zonex.get!("America/Chicago", ~U[2022-01-01 00:00:00Z]).offset == -21_600
    assert Zonex.get!("America/Chicago", ~U[2022-06-01 00:00:00Z]).offset == -18_000
  end

  test "formats offsets" do
    assert Zonex.get!("America/Chicago", ~U[2022-01-01 00:00:00Z]).formatted_offset == "GMT-06:00"
    assert Zonex.get!("America/Chicago", ~U[2022-06-01 00:00:00Z]).formatted_offset == "GMT-05:00"
  end

  test "includes a common name for all listed zones" do
    Enum.each(listed_zones(), fn %{common_name: common_name} ->
      assert is_binary(common_name)
    end)
  end

  test "includes a parsed zone struct" do
    Enum.each(all_zones(), fn %{zone: zone} ->
      assert %Timex.TimezoneInfo{} = zone
    end)
  end

  defp all_zones do
    Zonex.list(now())
  end

  defp listed_zones do
    now()
    |> Zonex.list()
    |> Enum.filter(& &1.listed)
  end

  defp now do
    ~U[2022-06-01 00:00:00Z]
  end
end
