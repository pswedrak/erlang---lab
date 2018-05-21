%%%-------------------------------------------------------------------
%%% @author piotr
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. maj 2018 15:56
%%%-------------------------------------------------------------------
-module(pollution_gen_serverTest).
-author("piotr").
-include_lib("eunit/include/eunit.hrl").


getOneValue_test() ->
  pollution_gen_server:start(),
  pollution_gen_server:addStation("Aleja", {50.2, 40.2}),
  pollution_gen_server:addValue({50.2,40.2}, {{2018,04,16}, {21,36,14}}, "PM10", 24),
  pollution_gen_server:addValue("Aleja", {{2018,04,16}, {21,37,14}}, "PM10", 24),
  pollution_gen_server:addStation("Plac Sikorskiego", {47.4, 52.1}),
  pollution_gen_server:addValue({47.4, 52.1}, {{2018,04,18}, {10,36,14}}, "PM10", 142),
  pollution_gen_server:addValue({47.4, 52.1}, {{2018,04,18}, {10,36,14}}, "PM2,5", 2),
  [?assert( pollution_gen_server:getOneValue("Aleja", {{2018,04,16}, {21,36,14}}, "PM10") =:= 24),
    ?assert( pollution_gen_server:getOneValue("Plac Sikorskiego", {{2018,04,18}, {10,36,14}}, "PM2,5") =:= 2)
  ],
  pollution_gen_server:stop().

getStationMean_test() ->
  pollution_gen_server:start(),
  pollution_gen_server:addStation("Aleja", {50.2, 40.2}),
  pollution_gen_server:addValue({50.2,40.2}, {{2018,04,16}, {21,36,14}}, "PM10", 24),
  pollution_gen_server:addValue("Aleja", {{2018,04,16}, {21,37,14}}, "PM10", 36),
  pollution_gen_server:addStation("Plac Sikorskiego", {47.4, 52.1}),
  pollution_gen_server:addValue({47.4, 52.1}, {{2018,04,18}, {10,36,14}}, "PM10", 142),
  pollution_gen_server:addValue({47.4, 52.1}, {{2018,04,18}, {10,36,14}}, "PM2,5", 2),
  [?assert( pollution_gen_server:getStationMean("Aleja", "PM10") == 30),
    ?assert( pollution_gen_server:getStationMean({47.4, 52.1}, "PM2,5") == 2)
  ],
  pollution_gen_server:stop().

getDailyMean_test() ->
  pollution_gen_server:start(),
  pollution_gen_server:addStation("Aleja", {50.2, 40.2}),
  pollution_gen_server:addValue({50.2,40.2}, {{2018,04,16}, {21,36,14}}, "PM10", 24),
  pollution_gen_server:addValue("Aleja", {{2018,04,16}, {21,37,14}}, "PM10", 36),
  pollution_gen_server:addStation("Plac Sikorskiego", {47.4, 52.1}),
  pollution_gen_server:addValue({47.4, 52.1}, {{2018,04,16}, {10,36,14}}, "PM10", 120),
  pollution_gen_server:addValue({47.4, 52.1}, {{2018,04,16}, {10,36,14}}, "PM2,5", 2),
  pollution_gen_server:addValue("Aleja", {{2018,04,16}, {14,36,14}}, "PM2,5", 23),
  [?assert( pollution_gen_server:getDailyMean("PM10", {2018,04,16}) == 60),
    ?assert( pollution_gen_server:getDailyMean("PM2,5", {2018,04,16}) == 12.5)
  ],
  pollution_gen_server:stop().

getPredictedIndex_test() ->
  pollution_gen_server:start(),
  pollution_gen_server:addStation("Aleja", {50.2, 40.2}),
  pollution_gen_server:addValue({50.2,40.2}, {{2018,04,16}, {16,00,00}}, "PM10", 120),
  pollution_gen_server:addValue("Aleja", {{2018,04,16}, {18,00,00}}, "PM10", 12),
  pollution_gen_server:addStation("Plac Sikorskiego", {47.4, 52.1}),
  pollution_gen_server:addValue({47.4, 52.1}, {{2018,04,16}, {10,36,14}}, "PM10", 120),
  pollution_gen_server:addValue({47.4, 52.1}, {{2018,04,16}, {10,36,14}}, "PM2,5", 2),
  pollution_gen_server:addValue("Aleja", {{2018,04,16}, {14,36,14}}, "PM2,5", 23),
  pollution_gen_server:addValue("Aleja", {{2018,04,16}, {22,00,00}}, "PM10", 60),
  [?assert( pollution_gen_server:getPredictedIndex({50.2, 40.2}, {{2018,4,17}, {12,0,0}}, "PM10") == 54),
    ?assert( pollution_gen_server:getPredictedIndex({47.4, 52.1}, {{2018,4,17}, {9,0,0}}, "PM2,5") == 2)
  ],
  pollution_gen_server:stop().
