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
-export([createMonitor/0, crash/0]).
-export([addStation/3]).
-export([addValue/5]).
-export([removeValue/4]).
-export([getOneValue/4]).
-export([getStationMean/3]).
-export([getDailyMean/3]).
-export([getPredictedIndex/4]).

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
    true -> throw(station_already_exists)
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

checkIfAlreadyExists(_, _, []) -> false;
checkIfAlreadyExists({Date, Time}, Type, [#measurement{date = Date, time = Time, type = Type} | _]) -> true;
checkIfAlreadyExists({Date, Time}, Type, [_ | T]) -> checkIfAlreadyExists({Date, Time}, Type, T).


addValue({X, Y}, {Date, Time}, Type, Value, Monitor) ->
  case keysContainStation(maps:keys(Monitor), name, {X, Y}) of
    false -> throw(station_does_not_exist);
    true -> case checkIfAlreadyExists({Date, Time}, Type, maps:get(getStation({coordinates, X, Y},  maps:keys(Monitor)), Monitor )) of
              false -> Monitor#{getStation({coordinates, X, Y}, maps:keys(Monitor)) := maps:get(getStation({coordinates, X, Y}, maps:keys(Monitor)), Monitor)
++ [#measurement{date = Date, time = Time, type = Type, value = Value}]};
              true -> throw(measurement_already_exists)
            end
  end;

addValue(Name, {Date, Time}, Type, Value, Monitor) ->
  case keysContainStation(maps:keys(Monitor), Name, {x, y}) of
    false -> throw(station_does_not_exist);
    true -> case checkIfAlreadyExists({Date, Time}, Type, maps:get(getStation(Name,  maps:keys(Monitor)), Monitor )) of
             false ->  Monitor#{getStation(Name, maps:keys(Monitor)) := maps:get(getStation(Name, maps:keys(Monitor)), Monitor)
                ++ [#measurement{date = Date, time = Time, type = Type, value = Value}]};
             true -> throw(measurement_already_exists)
            end
  end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

getMeasurement(_, _, []) -> throw(no_measurement);
getMeasurement({Date, Time}, Type, [H | T])
  -> case H of
       #measurement{date = Date, time = Time, type = Type} -> H;
       _ -> getMeasurement({Date, Time}, Type, T)
      end.

removeValue({X, Y}, {Date, Time}, Type, Monitor) ->
  case keysContainStation(maps:keys(Monitor), name, {X, Y}) of
    false -> throw(station_does_not_exist);
    true -> Monitor#{getStation({coordinates, X, Y}, maps:keys(Monitor)) := maps:get(getStation({coordinates, X, Y}, maps:keys(Monitor)), Monitor) --
            [getMeasurement({Date, Time}, Type, maps:get(getStation({coordinates, X, Y}, maps:keys(Monitor)), Monitor))]}
  end;

removeValue(Name,  {Date, Time}, Type, Monitor) ->
  case keysContainStation(maps:keys(Monitor), Name, {x, y}) of
    false -> throw(station_does_not_exist);
    true -> Monitor#{getStation(Name, maps:keys(Monitor)) := maps:get(getStation(Name, maps:keys(Monitor)), Monitor) --
         [getMeasurement({Date, Time}, Type, maps:get(getStation(Name, maps:keys(Monitor)), Monitor))]}
  end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

getValue(_, _, [])
  -> throw(no_measurement);
getValue({Date, Time}, Type, [#measurement{date = Date, time = Time, type = Type, value = X} | T]) -> X;
getValue({Date, Time}, Type, [_ | T]) -> getValue({Date, Time}, Type, T).

getOneValue({X, Y}, {Date, Time}, Type, Monitor) ->
  case keysContainStation(maps:keys(Monitor), name, {X, Y}) of
    false -> throw(station_does_not_exist);
    true -> getValue({Date, Time}, Type, maps:get(getStation({coordinates, X, Y}, maps:keys(Monitor)), Monitor))
  end;

getOneValue(Name, {Date, Time}, Type, Monitor) ->
  case keysContainStation(maps:keys(Monitor), Name, {x,y}) of
    false -> throw(station_does_not_exist);
    true -> getValue({Date, Time}, Type, maps:get(getStation(Name, maps:keys(Monitor)), Monitor))
  end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
getStationSumAndAmount(_, [], {Acc, N}) -> {Acc, N};
getStationSumAndAmount(Type, [#measurement{type = Type, value = X} | T], {Acc, N}) -> getStationSumAndAmount(Type, T, {Acc + X, N+1});
getStationSumAndAmount(Type, [_ | T], {Acc, N}) -> getStationSumAndAmount(Type, T, {Acc, N}).

getStationMean({X, Y}, Type, Monitor) ->
  case keysContainStation(maps:keys(Monitor), name, {X, Y}) of
    false -> throw(station_does_not_exist);
    true -> {Sum, N} = getStationSumAndAmount(Type, maps:get(getStation({coordinates, X, Y}, maps:keys(Monitor)), Monitor), {0 ,0}),
      case N of
              0 -> throw(no_measurement);
              _ -> Sum / N
            end
  end;

getStationMean(Name, Type, Monitor) ->
  case keysContainStation(maps:keys(Monitor), Name, {x, y}) of
    false -> throw(station_does_not_exist);
    true -> {Sum, N} = getStationSumAndAmount(Type, maps:get(getStation(Name, maps:keys(Monitor)), Monitor), {0,0}),
            case N of
              0 -> throw(no_measurement);
              _ -> Sum / N
            end
  end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

getDailyStationSumAndAmount(_, _, [], {Acc, N}) -> {Acc, N};
getDailyStationSumAndAmount(Type, Date, [#measurement{type = Type, date = Date, value = X} | T], {Acc, N}) -> getDailyStationSumAndAmount(Type, Date, T, {Acc + X, N+1});
getDailyStationSumAndAmount(Type, Date, [_ | T], {Acc, N}) -> getDailyStationSumAndAmount(Type, Date, T, {Acc, N}).

getDailyMonitorSumAndAmount(_, _, [], {Acc, N}, _)
  -> {Acc, N};
getDailyMonitorSumAndAmount(Type, Date, [Station | T], {Acc, N}, Monitor)
  ->  {OneStationSum, OneStationN} = getDailyStationSumAndAmount(Type, Date, maps:get(Station, Monitor), {0, 0}),
      getDailyMonitorSumAndAmount(Type, Date, T, {Acc + OneStationSum, N + OneStationN }, Monitor).

getDailyMean(Type, Date, Monitor) ->
  case element(2, getDailyMonitorSumAndAmount(Type, Date, maps:keys(Monitor), {0,0}, Monitor )) of
    0 -> throw(no_measurement);
    _ -> {Sum, N} = getDailyMonitorSumAndAmount(Type, Date, maps:keys(Monitor), {0,0}, Monitor ),
         Sum / N
  end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

getLastDayMeasurements(_, [], Acc) -> Acc;
getLastDayMeasurements({Date, Time}, [H | T], Acc)
  -> case element(1, calendar:time_difference({H#measurement.date, H#measurement.time}, {Date, Time})) of
       0 -> getLastDayMeasurements({Date, Time}, T, Acc ++ [H]);
       _ -> getLastDayMeasurements({Date, Time}, T, Acc)
     end.

lessThan(List, Arg) -> lists:filter(fun (X) -> calendar:datetime_to_gregorian_seconds( {X#measurement.date, X#measurement.time} )
                        < calendar:datetime_to_gregorian_seconds( {Arg#measurement.date, Arg#measurement.time} ) end, List).
grtEqThan(List, Arg) -> lists:filter(fun (X) -> calendar:datetime_to_gregorian_seconds( {X#measurement.date, X#measurement.time} )
                        >= calendar:datetime_to_gregorian_seconds( {Arg#measurement.date, Arg#measurement.time} ) end, List).

qsDate([Pivot | Tail]) -> qsDate(lessThan(Tail, Pivot)) ++ [Pivot] ++ qsDate(grtEqThan(Tail, Pivot));
qsDate([]) -> [].

filterType(Type, List) -> lists:filter(fun (X) -> X#measurement.type == Type end, List).

getMovingSumAndAmount([], {Sum, N, _}) -> {Sum, N};
getMovingSumAndAmount([H | T], {Sum, N, Weight}) -> getMovingSumAndAmount(T, {Sum + Weight * H#measurement.value, N + Weight, Weight + 1}).

getPredictedIndex({X, Y}, {Date, Time}, Type, Monitor)
  -> case keysContainStation(maps:keys(Monitor), name, {X, Y}) of
       false -> throw(station_does_not_exist);
       true -> {Sum, N} = getMovingSumAndAmount(filterType(Type, qsDate(getLastDayMeasurements({Date, Time}, maps:get(getStation({coordinates, X, Y}, maps:keys(Monitor)), Monitor), []))), {0,0,1}),
         case N of
                 0 -> throw(no_measurement);
                 _ -> Sum / N
               end
end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

crash() -> 1/0.