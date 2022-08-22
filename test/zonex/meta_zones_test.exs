defmodule Zonex.MetaZonesTest do
  @moduledoc false

  use ExUnit.Case

  alias Zonex.MetaZones
  alias Zonex.MetaZones.Rule

  test "builds rules" do
    assert MetaZones.rules()["Europe/Vilnius"] == [
             %Rule{from: nil, mzone: "Moscow", to: ~U[1989-03-25 23:00:00Z]},
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
               to: nil
             }
           ]
  end
end
