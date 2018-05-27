%%%-------------------------------------------------------------------
%%% @author piotr
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. maj 2018 14:04
%%%-------------------------------------------------------------------
-module(pollution_gen_server).
-behaviour(gen_server).
-author("piotr").

%% API
-export([start_link/1, init/1, handle_cast/2, handle_call/3]).
-export([start/0, stop/0, crash/0]).
-export([addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2, getPredictedIndex/3]).

start() ->
    start_link(pollution:createMonitor()).

start_link(Monitor) -> gen_server:start_link({local, pollution_gen_server}, pollution_gen_server, Monitor, []).

init(Monitor) ->
    {ok, Monitor}.

stop() ->
  gen_server:stop(pollution_gen_server).

handle_cast(stop, Monitor)
    -> {stop, kill, Monitor};

handle_cast( {addStation, {Name, {X, Y}}} , Monitor)
    -> {noreply, pollution:addStation(Name, {X, Y}, Monitor)};

handle_cast( {addValue, {{X, Y}, {Date, Time}, Type, Value}} , Monitor)
    -> {noreply, pollution:addValue({X, Y}, {Date, Time}, Type, Value, Monitor)};

handle_cast( {addValue, {Name, {Date, Time}, Type, Value}} , Monitor)
    -> {noreply, pollution:addValue(Name, {Date, Time}, Type, Value, Monitor)};

handle_cast( {removeValue, {Name, {Date, Time}, Type}}, Monitor)
    -> {noreply, pollution:removeValue(Name, {Date, Time}, Type, Monitor)};

handle_cast( {removeValue, {{X, Y}, {Date, Time}, Type}} , Monitor)
    -> {noreply, pollution:removeValue({X, Y}, {Date, Time}, Type, Monitor)};

handle_cast( {removeValue, {{X, Y}, {Date, Time}, Type}} , Monitor)
    -> {noreply, pollution:removeValue({X, Y}, {Date, Time}, Type, Monitor)};

handle_cast( crash, Monitor)
  -> {noreply, pollution:crash()}.

handle_call( {getOneValue, {{X, Y}, {Date, Time}, Type}}, Pid, Monitor)
    -> {reply, pollution:getOneValue({X, Y}, {Date, Time}, Type, Monitor), Monitor};

handle_call( {getOneValue, {Name, {Date, Time}, Type}}, Pid, Monitor)
    -> {reply, pollution:getOneValue(Name, {Date, Time}, Type, Monitor), Monitor};

handle_call( {getStationMean, {{X, Y}, Type}}, Pid, Monitor)
    -> {reply, pollution:getStationMean({X, Y}, Type, Monitor), Monitor};

handle_call( {getStationMean, {Name, Type}}, Pid, Monitor)
    -> {reply, pollution:getStationMean(Name, Type, Monitor), Monitor};

handle_call( {getDailyMean, {Type, Date}}, Pid, Monitor)
    -> {reply, pollution:getDailyMean(Type, Date, Monitor), Monitor};

handle_call( {getPredictedIndex, {X, Y}, {Date, Time}, Type}, Pid, Monitor)
    -> {reply, pollution:getPredictedIndex({X, Y}, {Date, Time}, Type, Monitor), Monitor}.

addStation(Name, {X, Y})
    -> gen_server:cast(pollution_gen_server, {addStation, {Name, {X, Y}}} ).

addValue({X, Y}, {Date, Time}, Type, Value)
    -> gen_server:cast(pollution_gen_server, {addValue, {{X, Y}, {Date, Time}, Type, Value}} );

addValue(Name, {Date, Time}, Type, Value)
    -> gen_server:cast(pollution_gen_server, {addValue, {Name, {Date, Time}, Type, Value}} ).

removeValue({X, Y}, {Date, Time}, Type)
    -> gen_server:cast(pollution_gen_server, {removeValue, {{X, Y}, {Date, Time}, Type}});

removeValue(Name, {Date, Time}, Type)
    -> gen_server:cast(pollution_gen_server, {removeValue, {Name, {Date, Time}, Type}}).

getOneValue({X, Y}, {Date, Time}, Type)
    -> gen_server:call(pollution_gen_server, {getOneValue, {{X, Y}, {Date, Time}, Type}});

getOneValue(Name, {Date, Time}, Type)
    -> gen_server:call(pollution_gen_server, {getOneValue, {Name, {Date, Time}, Type}}).

getStationMean({X, Y}, Type)
    -> gen_server:call(pollution_gen_server, {getStationMean, {{X, Y}, Type}});

getStationMean(Name, Type)
    -> gen_server:call(pollution_gen_server, {getStationMean, {Name, Type}}).

getDailyMean(Type, Date)
    -> gen_server:call(pollution_gen_server, {getDailyMean, {Type, Date}}).

getPredictedIndex({X, Y}, {Date, Time}, Type)
    -> gen_server:call(pollution_gen_server, {getPredictedIndex, {X, Y}, {Date, Time}, Type}).

crash()
    -> gen_server:cast(pollution_gen_server, crash).

