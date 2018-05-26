defmodule PollutionData do
  @moduledoc false

  def importLinesFromCSV(name) do
    File.read!(name) |> String.split("\r\n")
  end

  def parseLine(line) do
    [date_string, time_string, locationX_string, locationY_string, pollutionLevel_string] = String.split(line, ",")
    date = date_string |> String.split("-") |> Enum.reverse() |> Enum.map(fn x -> elem(Integer.parse(x),0) end) |> :erlang.list_to_tuple
    time = time_string |> String.split(":") |> Enum.map(fn x -> elem(Integer.parse(x),0) end)
    time = time ++ [0] |> :erlang.list_to_tuple

    locationX = elem(Float.parse(locationX_string),0)
    locationY = elem(Float.parse(locationY_string),0)
    pollutionLevel = elem(Integer.parse(pollutionLevel_string),0)

    record_map = %{}
    record_map = Map.put(record_map, :datetime, {date, time})
    record_map = Map.put(record_map, :location, {locationX, locationY})
    record_map = Map.put(record_map, :pollutionLevel, pollutionLevel)
  end

  def identifyStations(name) do
      list = importLinesFromCSV(name)
      Enum.reduce(list, [], fn line, acc -> [parseLine(line) | acc] end)
  end

end
