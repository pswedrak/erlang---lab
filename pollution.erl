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
    true -> maps:get(getStation({coordinates, X, Y}, maps:keys(Monitor)), Monitor)
  end.





