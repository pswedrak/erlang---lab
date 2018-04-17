%%%-------------------------------------------------------------------
%%% @author piotr
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. kwi 2018 12:51
%%%-------------------------------------------------------------------
-module(pollutionTest).
-author("piotr").

-include_lib("eunit/include/eunit.hrl").

createMonitor_test() ->
  ?assert(pollution:createMonitor() =:= #{}).

addStation_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("Aleja", {50.2, 40.2}, P),
  P2 = pollution:addStation("Aleja2", {50.2, 30.2}, P1),
  [?assert(P1 =:= #{{station, "Aleja", {coordinates, 50.2, 40.2}} => []}),
    ?assert(P2 =:= #{{station, "Aleja", {coordinates, 50.2, 40.2}} => [], {station, "Aleja2", {coordinates, 50.2, 30.2}} => []} )
    ].

addStation2_test() -> try pollution:addStation("Aleja2", {50.2, 40.2}, #{{station, "Aleja", {coordinates, 50.2, 40.2}} => []}) of
                        _ -> ?assert(false)
                      catch
                        throw:station_already_exists -> ?assert(true)
                      end.

addStation3_test() -> try pollution:addStation("Aleja", {40.2, 40.2}, #{{station, "Aleja", {coordinates, 50.2, 40.2}} => []}) of
                        _ -> ?assert(false)
                      catch
                        throw:station_already_exists -> ?assert(true)
                      end.

addValue_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("Aleja", {50.2, 40.2}, P),
  P2 = pollution:addValue({50.2,40.2}, {{2018,04,16}, {21,36,14}}, "PM10", 24, P1),
  P3 = pollution:addValue("Aleja", {{2018,04,16}, {21,37,14}}, "PM10", 24, P2),
  [?assert(P2 =:= #{{station, "Aleja", {coordinates, 50.2, 40.2}} => [{measurement,{2018,4,16},{21,36,14},"PM10",24}]}),
    ?assert(P3 =:= #{{station, "Aleja", {coordinates, 50.2, 40.2}} => [{measurement,{2018,4,16},{21,36,14},"PM10",24}, {measurement,{2018,4,16},{21,37,14},"PM10",24}]})
    ].

addValue2_test() -> try pollution:addValue({50.2,40.2}, {{2018,04,16}, {21,36,14}}, "PM10", 24,  #{{station, "Aleja", {coordinates, 50.3, 40.2}} => []}) of
                        _ -> ?assert(false)
                      catch
                        throw:station_does_not_exist -> ?assert(true)
                      end.

addValue3_test() -> try pollution:addValue({50.2,40.2}, {{2018,04,16}, {21,36,14}}, "PM10", 24,  #{{station, "Aleja", {coordinates, 50.2, 40.2}} => [{measurement,{2018,4,16},{21,36,14},"PM10",24}]}) of
                      _ -> ?assert(false)
                    catch
                      throw:measurement_already_exists -> ?assert(true)
                    end.

removeValue_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("Aleja", {50.2, 40.2}, P),
  P2 = pollution:addValue({50.2,40.2}, {{2018,04,16}, {21,36,14}}, "PM10", 24, P1),
  P3 = pollution:addValue("Aleja", {{2018,04,16}, {21,37,14}}, "PM10", 24, P2),
  [?assert(pollution:removeValue("Aleja", {{2018,04,16}, {21,37,14}}, "PM10", P3) =:= P2),
    ?assert(pollution:removeValue("Aleja", {{2018,04,16}, {21,36,14}}, "PM10", P2) =:= P1)
  ].

getOneValue_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("Aleja", {50.2, 40.2}, P),
  P2 = pollution:addValue({50.2,40.2}, {{2018,04,16}, {21,36,14}}, "PM10", 24, P1),
  P3 = pollution:addValue("Aleja", {{2018,04,16}, {21,37,14}}, "PM10", 24, P2),
  P4 = pollution:addStation("Plac Sikorskiego", {47.4, 52.1}, P3),
  P5 = pollution:addValue({47.4, 52.1}, {{2018,04,18}, {10,36,14}}, "PM10", 142, P4),
  P6 = pollution:addValue({47.4, 52.1}, {{2018,04,18}, {10,36,14}}, "PM2,5", 2, P5),
  [?assert( pollution:getOneValue("Aleja", {{2018,04,16}, {21,36,14}}, "PM10",  P2 ) =:= 24),
    ?assert( pollution:getOneValue("Plac Sikorskiego", {{2018,04,18}, {10,36,14}}, "PM2,5", P6) =:= 2)
    ].

getStationMean_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("Aleja", {50.2, 40.2}, P),
  P2 = pollution:addValue({50.2,40.2}, {{2018,04,16}, {21,36,14}}, "PM10", 24, P1),
  P3 = pollution:addValue("Aleja", {{2018,04,16}, {21,37,14}}, "PM10", 36, P2),
  P4 = pollution:addStation("Plac Sikorskiego", {47.4, 52.1}, P3),
  P5 = pollution:addValue({47.4, 52.1}, {{2018,04,18}, {10,36,14}}, "PM10", 142, P4),
  P6 = pollution:addValue({47.4, 52.1}, {{2018,04,18}, {10,36,14}}, "PM2,5", 2, P5),
  [?assert( pollution:getStationMean("Aleja", "PM10",  P6 ) == 30),
    ?assert( pollution:getStationMean({47.4, 52.1}, "PM2,5", P6 ) == 2)
  ].

getDailyMean_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("Aleja", {50.2, 40.2}, P),
  P2 = pollution:addValue({50.2,40.2}, {{2018,04,16}, {21,36,14}}, "PM10", 24, P1),
  P3 = pollution:addValue("Aleja", {{2018,04,16}, {21,37,14}}, "PM10", 36, P2),
  P4 = pollution:addStation("Plac Sikorskiego", {47.4, 52.1}, P3),
  P5 = pollution:addValue({47.4, 52.1}, {{2018,04,16}, {10,36,14}}, "PM10", 120, P4),
  P6 = pollution:addValue({47.4, 52.1}, {{2018,04,16}, {10,36,14}}, "PM2,5", 2, P5),
  P7 = pollution:addValue("Aleja", {{2018,04,16}, {14,36,14}}, "PM2,5", 23, P6),
  [?assert( pollution:getDailyMean("PM10", {2018,04,16},  P7 ) == 60),
    ?assert( pollution:getDailyMean("PM2,5", {2018,04,16}, P7 ) == 12.5)
  ].

getPredictedIndex_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("Aleja", {50.2, 40.2}, P),
  P2 = pollution:addValue({50.2,40.2}, {{2018,04,16}, {16,00,00}}, "PM10", 120, P1),
  P3 = pollution:addValue("Aleja", {{2018,04,16}, {18,00,00}}, "PM10", 12, P2),
  P4 = pollution:addStation("Plac Sikorskiego", {47.4, 52.1}, P3),
  P5 = pollution:addValue({47.4, 52.1}, {{2018,04,16}, {10,36,14}}, "PM10", 120, P4),
  P6 = pollution:addValue({47.4, 52.1}, {{2018,04,16}, {10,36,14}}, "PM2,5", 2, P5),
  P7 = pollution:addValue("Aleja", {{2018,04,16}, {14,36,14}}, "PM2,5", 23, P6),
  P8 = pollution:addValue("Aleja", {{2018,04,16}, {22,00,00}}, "PM10", 60, P7),
  [?assert( pollution:getPredictedIndex({50.2, 40.2}, {{2018,4,17}, {12,0,0}}, "PM10", P8 ) == 54),
    ?assert( pollution:getPredictedIndex({47.4, 52.1}, {{2018,4,17}, {9,0,0}}, "PM2,5", P8 ) == 2)
  ].
