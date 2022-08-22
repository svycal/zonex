defmodule Zonex.WindowsZones do
  @moduledoc """
  Windows zone data.
  """

  use GenServer

  @type standard_name :: String.t()
  @type common_name :: String.t()

  import SweetXml

  # Client

  @doc """
  Starts the process.
  """
  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  A mapping of Olson time zone names to "standard" names from the windows zones file.
  (e.g. America/Chicago -> Central Standard Time).
  """
  @spec standard_names() :: %{Calendar.time_zone() => standard_name()}
  def standard_names do
    GenServer.call(__MODULE__, :standard_names)
  end

  @doc """
  A mapping of "standard" time zone names from the windows zones file
  to "common" names (e.g. Central Standard Time -> Central Time (US & Canada)).
  """
  @spec common_names() :: %{standard_name() => common_name()}
  def common_names do
    %{
      "Dateline Standard Time" => "International Date Line West",
      "UTC-11" => "Coordinated Universal Time-11",
      "Aleutian Standard Time" => "Aleutian Islands",
      "Hawaiian Standard Time" => "Hawaii",
      "Marquesas Standard Time" => "Marquesas Islands",
      "Alaskan Standard Time" => "Alaska",
      "UTC-09" => "Coordinated Universal Time-09",
      "Pacific Standard Time (Mexico)" => "Baja California",
      "UTC-08" => "Coordinated Universal Time-08",
      "Pacific Standard Time" => "Pacific Time (US & Canada)",
      "US Mountain Standard Time" => "Arizona",
      "Mountain Standard Time (Mexico)" => "Chihuahua, La Paz, Mazatlan",
      "Mountain Standard Time" => "Mountain Time (US & Canada)",
      "Yukon Standard Time" => "Yukon",
      "Central America Standard Time" => "Central America",
      "Central Standard Time" => "Central Time (US & Canada)",
      "Easter Island Standard Time" => "Easter Island",
      "Central Standard Time (Mexico)" => "Guadalajara, Mexico City, Monterrey",
      "Canada Central Standard Time" => "Saskatchewan",
      "SA Pacific Standard Time" => "Bogota, Lima, Quito, Rio Branco",
      "Eastern Standard Time (Mexico)" => "Chetumal",
      "Eastern Standard Time" => "Eastern Time (US & Canada)",
      "Haiti Standard Time" => "Haiti",
      "Cuba Standard Time" => "Havana",
      "US Eastern Standard Time" => "Indiana (East)",
      "Turks And Caicos Standard Time" => "Turks and Caicos",
      "Paraguay Standard Time" => "Asuncion",
      "Atlantic Standard Time" => "Atlantic Time (Canada)",
      "Venezuela Standard Time" => "Caracas",
      "Central Brazilian Standard Time" => "Cuiaba",
      "SA Western Standard Time" => "Georgetown, La Paz, Manaus, San Juan",
      "Pacific SA Standard Time" => "Santiago",
      "Newfoundland Standard Time" => "Newfoundland",
      "Tocantins Standard Time" => "Araguaina",
      "E. South America Standard Time" => "Brasilia",
      "SA Eastern Standard Time" => "Cayenne, Fortaleza",
      "Argentina Standard Time" => "City of Buenos Aires",
      "Greenland Standard Time" => "Greenland",
      "Montevideo Standard Time" => "Montevideo",
      "Magallanes Standard Time" => "Punta Arenas",
      "Saint Pierre Standard Time" => "Saint Pierre and Miquelon",
      "Bahia Standard Time" => "Salvador",
      "UTC-02" => "Coordinated Universal Time-02",
      "Azores Standard Time" => "Azores",
      "Cape Verde Standard Time" => "Cabo Verde Is.",
      "UTC" => "Coordinated Universal Time",
      "GMT Standard Time" => "Dublin, Edinburgh, Lisbon, London",
      "Greenwich Standard Time" => "Monrovia, Reykjavik",
      "Sao Tome Standard Time" => "Sao Tome",
      "Morocco Standard Time" => "Casablanca",
      "W. Europe Standard Time" => "Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna",
      "Central Europe Standard Time" => "Belgrade, Bratislava, Budapest, Ljubljana, Prague",
      "Romance Standard Time" => "Brussels, Copenhagen, Madrid, Paris",
      "Central European Standard Time" => "Sarajevo, Skopje, Warsaw, Zagreb",
      "W. Central Africa Standard Time" => "West Central Africa",
      "Jordan Standard Time" => "Amman",
      "GTB Standard Time" => "Athens, Bucharest",
      "Middle East Standard Time" => "Beirut",
      "Egypt Standard Time" => "Cairo",
      "E. Europe Standard Time" => "Chisinau",
      "Syria Standard Time" => "Damascus",
      "West Bank Standard Time" => "Gaza, Hebron",
      "South Africa Standard Time" => "Harare, Pretoria",
      "FLE Standard Time" => "Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius",
      "Israel Standard Time" => "Jerusalem",
      "South Sudan Standard Time" => "Juba",
      "Kaliningrad Standard Time" => "Kaliningrad",
      "Sudan Standard Time" => "Khartoum",
      "Libya Standard Time" => "Tripoli",
      "Namibia Standard Time" => "Windhoek",
      "Arabic Standard Time" => "Baghdad",
      "Turkey Standard Time" => "Istanbul",
      "Arab Standard Time" => "Kuwait, Riyadh",
      "Belarus Standard Time" => "Minsk",
      "Russian Standard Time" => "Moscow, St. Petersburg",
      "E. Africa Standard Time" => "Nairobi",
      "Iran Standard Time" => "Tehran",
      "Arabian Standard Time" => "Abu Dhabi, Muscat",
      "Astrakhan Standard Time" => "Astrakhan, Ulyanovsk",
      "Azerbaijan Standard Time" => "Baku",
      "Russia Time Zone 3" => "Izhevsk, Samara",
      "Mauritius Standard Time" => "Port Louis",
      "Saratov Standard Time" => "Saratov",
      "Georgian Standard Time" => "Tbilisi",
      "Volgograd Standard Time" => "Volgograd",
      "Caucasus Standard Time" => "Yerevan",
      "Afghanistan Standard Time" => "Kabul",
      "West Asia Standard Time" => "Ashgabat, Tashkent",
      "Ekaterinburg Standard Time" => "Ekaterinburg",
      "Pakistan Standard Time" => "Islamabad, Karachi",
      "Qyzylorda Standard Time" => "Qyzylorda",
      "India Standard Time" => "Chennai, Kolkata, Mumbai, New Delhi",
      "Sri Lanka Standard Time" => "Sri Jayawardenepura",
      "Nepal Standard Time" => "Kathmandu",
      "Central Asia Standard Time" => "Astana",
      "Bangladesh Standard Time" => "Dhaka",
      "Omsk Standard Time" => "Omsk",
      "Myanmar Standard Time" => "Yangon (Rangoon)",
      "SE Asia Standard Time" => "Bangkok, Hanoi, Jakarta",
      "Altai Standard Time" => "Barnaul, Gorno-Altaysk",
      "W. Mongolia Standard Time" => "Hovd",
      "North Asia Standard Time" => "Krasnoyarsk",
      "N. Central Asia Standard Time" => "Novosibirsk",
      "Tomsk Standard Time" => "Tomsk",
      "China Standard Time" => "Beijing, Chongqing, Hong Kong, Urumqi",
      "North Asia East Standard Time" => "Irkutsk",
      "Singapore Standard Time" => "Kuala Lumpur, Singapore",
      "W. Australia Standard Time" => "Perth",
      "Taipei Standard Time" => "Taipei",
      "Ulaanbaatar Standard Time" => "Ulaanbaatar",
      "Aus Central W. Standard Time" => "Eucla",
      "Transbaikal Standard Time" => "Chita",
      "Tokyo Standard Time" => "Osaka, Sapporo, Tokyo",
      "North Korea Standard Time" => "Pyongyang",
      "Korea Standard Time" => "Seoul",
      "Yakutsk Standard Time" => "Yakutsk",
      "Cen. Australia Standard Time" => "Adelaide",
      "AUS Central Standard Time" => "Darwin",
      "E. Australia Standard Time" => "Brisbane",
      "AUS Eastern Standard Time" => "Canberra, Melbourne, Sydney",
      "West Pacific Standard Time" => "Guam, Port Moresby",
      "Tasmania Standard Time" => "Hobart",
      "Vladivostok Standard Time" => "Vladivostok",
      "Lord Howe Standard Time" => "Lord Howe Island",
      "Bougainville Standard Time" => "Bougainville Island",
      "Russia Time Zone 10" => "Chokurdakh",
      "Magadan Standard Time" => "Magadan",
      "Norfolk Standard Time" => "Norfolk Island",
      "Sakhalin Standard Time" => "Sakhalin",
      "Central Pacific Standard Time" => "Solomon Is., New Caledonia",
      "Russia Time Zone 11" => "Anadyr, Petropavlovsk-Kamchatsky",
      "New Zealand Standard Time" => "Auckland, Wellington",
      "UTC+12" => "Coordinated Universal Time+12",
      "Fiji Standard Time" => "Fiji",
      "Chatham Islands Standard Time" => "Chatham Islands",
      "UTC+13" => "Coordinated Universal Time+13",
      "Tonga Standard Time" => "Nuku'alofa",
      "Samoa Standard Time" => "Samoa",
      "Line Islands Standard Time" => "Kiritimati Island"
    }
  end

  # Server

  @impl GenServer
  def init(_arg) do
    path = Application.app_dir(:zonex, "priv/windowsZones.xml")
    contents = File.read!(path)
    {:ok, parse_contents(contents)}
  end

  @impl GenServer
  def handle_call(:standard_names, _from, state) do
    {:reply, state, state}
  end

  # Private helpers

  defp parse_contents(contents) do
    contents
    |> parse_xml()
    |> xpath(~x"//supplementalData/windowsZones/mapTimezones/mapZone[@territory='001']"el,
      name: ~x"./@type"s,
      standard_name: ~x"./@other"s
    )
    |> Enum.map(&{&1[:name], &1[:standard_name]})
    |> Map.new()
  end

  defp parse_xml(xml) do
    {:ok, root} = Saxmerl.parse_string(xml, dynamic_atoms: true)
    root
  end
end
