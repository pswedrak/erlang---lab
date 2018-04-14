%%%-------------------------------------------------------------------
%%% @author piotr
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. mar 2018 17:00
%%%-------------------------------------------------------------------
-module(pollution).
-author("piotr").
-export([createMonitor/0]).
-export([addStation/3]).
-export([addValue/5]).
-export([getOneValue/4]).
-export([getStationMean/3]).

-record(coordinates, {longitude, latitude}).
-record(station, {name, coordinates}).
-record(date, {year, month, day}).
-record(time, {hour, minute, second}).
-record(measurement, {date, time, type, value}).

createMonitor() -> #{}.

keysContainStation([], _, _)
  -> false;
keysContainStation([#station{name = Name}| _], Name, {X, Y})
  -> true;
keysContainStation([#station{coordinates = #coordinates{longitude = X, latitude = Y}}| _], Name, {X, Y})
  -> true;
keysContainStation([_ | T], Name, {X, Y})
  -> keysContainStation(T, Name,{X, Y}).


addStation(Name, {X, Y}, Monitor) ->
  case keysContainStation(maps:keys(Monitor), Name, {X, Y}) of
    false -> Monitor#{#station{name = Name, coordinates = #coordinates{longitude = X, latitude = Y}} => []};
    true -> throw("Station already exists")
  end.

getStation(_, [])
  -> throw("No such station");

getStation({coordinates, X, Y}, [H | T])
  -> case H of
       #station{coordinates = {coordinates, X, Y}} -> H;
       _ -> getStation({coordinates, X, Y}, T)
     end;

getStation(Name, [H | T])
  -> case H of
      #station{name = Name} -> H;
      _ -> getStation(Name, T)
     end.

addValue({X, Y}, {Date, Time}, Type, Value, Monitor) ->
  case keysContainStation(maps:keys(Monitor), name, {X, Y}) of
    false -> throw("Station does not exist");
    true -> Monitor#{getStation({coordinates, X, Y}, maps:keys(Monitor)) := maps:get(getStation({coordinates, X, Y}, maps:keys(Monitor)), Monitor) ++ [#measurement{date = Date, time = Time, type = Type, value = Value}]}
  end;

addValue(Name, {Date, Time}, Type, Value, Monitor) ->
  case keysContainStation(maps:keys(Monitor), Name, {x, y}) of
    false -> throw("Station does not exist");
    true -> Monitor#{getStation(Name, maps:keys(Monitor)) := maps:get(getStation(Name, maps:keys(Monitor)), Monitor) ++ [#measurement{date = Date, time = Time, type = Type, value = Value}]}
  end.

getOneValue({X, Y}, {Date, Time}, Type, Monitor) ->
  case keysContainStation(maps:keys(Monitor), name, {X, Y}) of
    false -> throw("Station does not exist");
    true -> getValue({Date, Time}, Type, maps:get(getStation({coordinates, X, Y}, maps:keys(Monitor)), Monitor))
  end;

getOneValue(Name, {Date, Time}, Type, Monitor) ->
  case keysContainStation(maps:keys(Monitor), Name, {x,y}) of
    false -> throw("Station does not exist");
    true -> getValue({Date, Time}, Type, maps:get(getStation(Name, maps:keys(Monitor)), Monitor))
  end.

getValue({Date, Time}, Type, [])
  -> throw("There is no such measurement");
getValue({Date, Time}, Type, [H | T])
  -> case H of
       #measurement{date = Date, time = Time, type = Type} -> H#measurement.value;
       _ -> getValue({Date, Time}, Type, T)
     end.

getStationMean({X, Y}, Type, Monitor) ->
  case keysContainStation(maps:keys(Monitor), name, {X, Y}) of
    false -> throw("Station does not exist");
    true -> case getNumberOfMeasurements(Type, maps:get(getStation({coordinates, X, Y}, maps:keys(Monitor)), Monitor), 0) of
              0 -> throw("There are no such measurements");
              _ -> getStationSum(Type, maps:get(getStation({coordinates, X, Y}, maps:keys(Monitor)), Monitor), 0)
                    / getNumberOfMeasurements(Type, maps:get(getStation({coordinates, X, Y}, maps:keys(Monitor)), Monitor), 0)
            end
  end;

getStationMean(Name, Type, Monitor) ->
  case keysContainStation(maps:keys(Monitor), Name, {x, y}) of
    false -> throw("Station does not exist");
    true -> case getNumberOfMeasurements(Type, maps:get(getStation(Name, maps:keys(Monitor)), Monitor), 0) of
              0 -> throw("There are no such measurements");
              _ -> getStationSum(Type, maps:get(getStation(Name, maps:keys(Monitor)), Monitor), 0)
                / getNumberOfMeasurements(Type, maps:get(getStation(Name, maps:keys(Monitor)), Monitor), 0)
            end
  end.

getStationSum(_, [], Acc) -> Acc;
getStationSum(Type, [H | T], Acc)
  -> case H of
       #measurement{type = Type} -> getStationSum(Type, T, Acc + H#measurement.value);
       _ -> getStationSum(Type, T, Acc)
     end.

getNumberOfMeasurements(Type, [], N) -> N;
getNumberOfMeasurements(Type, [H | T], N)
  -> case H of
       #measurement{type = Type} -> getNumberOfMeasurements(Type, T, N + 1);
       _ -> getNumberOfMeasurements(Type, T, N)
     end.



