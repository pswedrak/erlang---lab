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

  def identifyStations(list) do
      mapa = list |> Enum.reduce(%{}, fn line, acc -> Map.put(acc, line[:location], []) end)
      Map.keys(mapa)
  end

  def startServer() do
    spawn fn -> :pollution_gen_server.start() end
  end

  def stopServer() do
    :pollution_gen_server.stop()
  end

  def loadStations(list) do
    stations = identifyStations(list)
    Enum.map(stations, fn {x, y} -> :pollution_gen_server.addStation("station_#{x}_#{y}", {x, y}) end)
  end

  def loadRecords(list) do
    Enum.map(list, fn record -> :pollution_gen_server.addValue(record[:location], record[:datetime], "PM10", record[:pollutionLevel]) end)
  end

  def test(name) do
    startServer()

    file = importLinesFromCSV(name)
    list = Enum.reduce(file, [], fn line, acc -> [parseLine(line) | acc] end)

    stations_time = fn -> loadStations(list) end |> :timer.tc |> elem(0)
    records_time = fn -> loadRecords(list) end |> :timer.tc |> elem(0)
    #dailymean = fn -> :pollution_gen_server.getDailyMean({20.06, 49.986}, "PM10") end |> :timer.tc
    stopServer()
    {stations_time / 1000000, records_time / 1000000}
    #dailymean
  end

end
