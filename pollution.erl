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
-export([removeValue/4]).
-export([getOneValue/4]).
-export([getStationMean/3]).
-export([getDailyMean/3]).

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addStation(Name, {X, Y}, Monitor) ->
  case keysContainStation(maps:keys(Monitor), Name, {X, Y}) of
    false -> Monitor#{#station{name = Name, coordinates = #coordinates{longitude = X, latitude = Y}} => []};
    true -> throw("Station already exists")
  end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

getMeasurement(_, _, []) -> throw("No such measurement");
getMeasurement({Date, Time}, Type, [H | T])
  -> case H of
       #measurement{date = Date, time = Time, type = Type} -> H;
       _ -> getMeasurement({Date, Time}, Type, T)
      end.

removeValue({X, Y}, {Date, Time}, Type, Monitor) ->
  case keysContainStation(maps:keys(Monitor), name, {X, Y}) of
    false -> throw("Station does not exist");
    true -> Monitor#{getStation({coordinates, X, Y}, maps:keys(Monitor)) := maps:get(getStation({coordinates, X, Y}, maps:keys(Monitor)), Monitor) --
            [getMeasurement({Date, Time}, Type, maps:get(getStation({coordinates, X, Y}, maps:keys(Monitor)), Monitor))]}
  end;

removeValue(Name,  {Date, Time}, Type, Monitor) ->
  case keysContainStation(maps:keys(Monitor), Name, {x, y}) of
    false -> throw("Station does not exist");
    true -> Monitor#{getStation(Name, maps:keys(Monitor)) := maps:get(getStation(Name, maps:keys(Monitor)), Monitor) --
         [getMeasurement({Date, Time}, Type, maps:get(getStation(Name, maps:keys(Monitor)), Monitor))]}
  end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

getValue({Date, Time}, Type, [])
  -> throw("There is no such measurement");
getValue({Date, Time}, Type, [#measurement{date = Date, time = Time, type = Type, value = X} | T]) -> X;
getValue({Date, Time}, Type, [_ | T]) -> getValue({Date, Time}, Type, T).

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
getStationSumAndAmount(_, [], {Acc, N}) -> {Acc, N};
getStationSumAndAmount(Type, [#measurement{type = Type, value = X} | T], {Acc, N}) -> getStationSumAndAmount(Type, T, {Acc + X, N+1});
getStationSumAndAmount(Type, [_ | T], {Acc, N}) -> getStationSumAndAmount(Type, T, {Acc, N}).

getStationMean({X, Y}, Type, Monitor) ->
  case keysContainStation(maps:keys(Monitor), name, {X, Y}) of
    false -> throw("Station does not exist");
    true -> case element(2, getStationSumAndAmount(Type, maps:get(getStation({coordinates, X, Y}, maps:keys(Monitor)), Monitor), {0 ,0})) of
              0 -> throw("There are no such measurements");
              _ -> element(1, getStationSumAndAmount(Type, maps:get(getStation({coordinates, X, Y}, maps:keys(Monitor)), Monitor), {0 ,0}))
                    / element(2, getStationSumAndAmount(Type, maps:get(getStation({coordinates, X, Y}, maps:keys(Monitor)), Monitor), {0 ,0}))
            end
  end;

getStationMean(Name, Type, Monitor) ->
  case keysContainStation(maps:keys(Monitor), Name, {x, y}) of
    false -> throw("Station does not exist");
    true -> case element(2, getStationSumAndAmount(Type, maps:get(getStation(Name, maps:keys(Monitor)), Monitor), {0,0})) of
              0 -> throw("There are no such measurements");
              _ -> element(1, getStationSumAndAmount(Type, maps:get(getStation(Name, maps:keys(Monitor)), Monitor), {0,0}))
                / element(2, getStationSumAndAmount(Type, maps:get(getStation(Name, maps:keys(Monitor)), Monitor), {0,0}))
            end
  end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

getDailyStationSumAndAmount(Type, Date, [], {Acc, N}) -> {Acc, N};
getDailyStationSumAndAmount(Type, Date, [#measurement{type = Type, date = Date, value = X} | T], {Acc, N}) -> getDailyStationSumAndAmount(Type, Date, T, {Acc + X, N+1});
getDailyStationSumAndAmount(Type, Date, [_ | T], {Acc, N}) -> getDailyStationSumAndAmount(Type, Date, T, {Acc, N}).

getDailyMonitorSumAndAmount(Type, Date, [], {Acc, N})
  -> {Acc, N};
getDailyMonitorSumAndAmount(Type, Date, [Station | T], {Acc, N})
  -> getDailyMonitorSumAndAmount(Type, Date, T, {Acc + element(1, getDailyStationSumAndAmount(Type, Date, Station, {0, 0})), N + 1}).

getDailyMean(Type, Date, Monitor) ->
  case element(2, getDailyMonitorSumAndAmount(Type, Date, maps:keys(Monitor), {0,0} )) of
    0 -> throw("There are no such measurements");
    _ -> element(1, getDailyMonitorSumAndAmount(Type, Date, maps:keys(Monitor), {0,0} ))
          /  element(2, getDailyMonitorSumAndAmount(Type, Date, maps:keys(Monitor), {0,0}))
  end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%