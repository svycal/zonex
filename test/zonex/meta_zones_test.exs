defmodule Zonex.MetaZonesTest do
  @moduledoc false

  use ExUnit.Case

  alias Zonex.MetaZones
  alias Zonex.MetaZones.Rule

  test "builds a rule mapping" do
    assert MetaZones.rules_for_zone("Europe/Vilnius") == [
             %Rule{
               from: ~U[0000-01-01 00:00:00Z],
               mzone: "Moscow",
               to: ~U[1989-03-25 23:00:00Z]
             },
             %Rule{
               from: ~U[1989-03-25 23:00:00Z],
               mzone: "Europe_Eastern",
               to: ~U[1998-03-29 01:00:00Z]
             },
             %Rule{
               from: ~U[1998-03-29 01:00:00Z],
               mzone: "Europe_Central",
               to: ~U[1999-10-31 01:00:00Z]
             },
             %Rule{
               from: ~U[1999-10-31 01:00:00Z],
               mzone: "Europe_Eastern",
               to: ~U[9999-01-01 00:00:00Z]
             }
           ]
  end

  test "fetches the right meta zone based on range" do
    rules = MetaZones.rules_for_zone("Europe/Vilnius")
    assert MetaZones.resolve(rules, ~U[1989-03-26 23:00:00Z]) == {:ok, "Europe_Eastern"}
    assert MetaZones.resolve(rules, ~U[1998-03-30 23:00:00Z]) == {:ok, "Europe_Central"}
    assert MetaZones.resolve(rules, ~U[1990-11-01 23:00:00Z]) == {:ok, "Europe_Eastern"}
  end
end
