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

  def measureTime(n, {stations_time, records_time, m}, list) do
    case n do
      0 -> {stations_time / 1000000, records_time / 1000000}
      _ ->  startServer()
            time_s = fn -> loadStations(list) end |> :timer.tc |> elem(0)
            time_r = fn -> loadRecords(list) end |> :timer.tc |> elem(0)
            stopServer()
            measureTime(n-1, {stations_time + time_s/m, records_time + time_r/m, m}, list)
    end
  end

  def measureTime(n, {time, m}, f, 2, {x, y}, list) do
    case n do
      0 -> time / 1000000
      _ ->  startServer()
            loadStations(list)
            loadRecords(list)
            time1 = fn -> f.(x, y) end |> :timer.tc |> elem(0)
            stopServer()
            measureTime(n-1, {time + time1/m, m}, f, 2, {x, y}, list)
    end
    end

  def test(name) do

    file = importLinesFromCSV(name)
    list = Enum.reduce(file, [], fn line, acc -> [parseLine(line) | acc] end)

    mapa = list |> Enum.reduce(%{}, fn line, acc -> Map.put(acc, {line[:datetime], line[:location]}, line) end)
    list = Map.values(mapa)

    #{stations_time, records_time} = measureTime(100, {0,0,100}, list)

    #stations_mean_time = measureTime(1, {0, 1}, &:pollution_gen_server.getStationMean/2, 2, {{20.06, 49.986}, "PM10"}, list )

    #startServer()
    #loadStations(list)
    #loadRecords(list)
    #:pollution_gen_server.getStationMean({20.06, 49.986}, "PM10")

    #startServer()
    #loadStations(list)
    #loadRecords(list)
    #:pollution_gen_server.getDailyMean("PM10", {2017,5,3})

    #measureTime(1, {0, 1}, &:pollution_gen_server.getDailyMean/2, 2, {"PM10", {2017,5,3}}, list )

    #measureTime(1, {0, 1}, &:pollution_gen_server.getDailyMean/2, 2, {"PM10", {2017,5,3}}, list )

    startServer()
    loadStations(list)
    loadRecords(list)
    #:pollution_gen_server.getPredictedIndex({19.773,50.057}, {{2017,5,5}, {01,0,0}}, "PM10")
    time1 = fn -> :pollution_gen_server.getPredictedIndex({19.773,50.057}, {{2017,5,5}, {01,0,0}}, "PM10") end |> :timer.tc |> elem(0)
    stopServer()
    time1
  end

  def streamTest(name) do
    stream = File.stream!(name)
    Stream.map(stream, &importLinesFromCSV/1)
  end

end
