%%%-------------------------------------------------------------------
%%% @author piotr
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. kwi 2018 18:30
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("piotr").

%% API
-export([start/0]).
-export([stop/0]).
-export([init/0]).
-export([addStation/2]).
-export([addValue/4]).
-export([removeValue/3]).
-export([getOneValue/3]).
-export([getStationMean/2]).
-export([getDailyMean/2]).
-export([getPredictedIndex/3]).

start() ->
  register (pollServer, spawn(pollution_server, init, [])).

init() ->
  loop(pollution:createMonitor()).

loop(Monitor) ->
  receive
    {request, Pid, addStation, {Name, {X, Y}}} ->
      Pid ! {reply, ok},
      loop(pollution:addStation(Name, {X, Y}, Monitor));

    {request, Pid, addValue, {{X, Y}, {Date, Time}, Type, Value}} ->
      Pid ! {reply, ok},
      loop(pollution:addValue({X, Y}, {Date, Time}, Type, Value, Monitor));

    {request, Pid, addValue, {Name, {Date, Time}, Type, Value}} ->
      Pid ! {reply, ok},
      loop(pollution:addValue(Name, {Date, Time}, Type, Value, Monitor));

    {request, Pid, removeValue, {{X, Y}, {Date, Time}, Type}} ->
      Pid ! {reply, ok},
      loop(pollution:removeValue({X, Y}, {Date, Time}, Type, Monitor));

    {request, Pid, removeValue, {Name, {Date, Time}, Type}} ->
      Pid ! {reply, ok},
      loop(pollution:removeValue(Name, {Date, Time}, Type, Monitor));

    {request, Pid, getOneValue, {{X, Y}, {Date, Time}, Type}} ->
      Pid ! {reply, pollution:getOneValue({X, Y}, {Date, Time}, Type, Monitor)},
      loop(Monitor);

    {request, Pid, getOneValue, {Name, {Date, Time}, Type}} ->
      Pid ! {reply, pollution:getOneValue(Name, {Date, Time}, Type, Monitor)},
      loop(Monitor);

    {request, Pid, getStationMean, {{X, Y}, Type}} ->
      Pid ! {reply, pollution:getStationMean({X, Y}, Type, Monitor)},
      loop(Monitor);

    {request, Pid, getStationMean, {Name, Type}} ->
      Pid ! {reply, pollution:getStationMean(Name, Type, Monitor)},
      loop(Monitor);

    {request, Pid, getDailyMean, {Type, Date}} ->
      Pid ! {reply, pollution:getDailyMean(Type, Date, Monitor)},
      loop(Monitor);

    {request, Pid, getPredictedIndex, {{X, Y}, {Date, Time}, Type}} ->
      Pid ! {reply, pollution:getPredictedIndex({X, Y}, {Date, Time}, Type, Monitor)},
      loop(Monitor);

    {request, Pid, stop} ->
      ok
  end.

stop() -> pollServer ! {request, self(), stop}.

call(Type, Message) ->
  pollServer ! {request, self(), Type, Message},
  receive
    {reply, Reply} -> Reply
  end.

addStation(Name, {X, Y})
  -> call(addStation, {Name, {X, Y}}).

addValue({X, Y}, {Date, Time}, Type, Value)
  -> call(addValue, {{X, Y}, {Date, Time}, Type, Value} );

addValue(Name, {Date, Time}, Type, Value)
  -> call(addValue, {Name, {Date, Time}, Type, Value} ).

removeValue({X, Y}, {Date, Time}, Type)
  -> call(removeValue, {{X, Y}, {Date, Time}, Type});

removeValue(Name, {Date, Time}, Type)
  -> call(removeValue, {Name, {Date, Time}, Type}).

getOneValue({X, Y}, {Date, Time}, Type)
  -> call(getOneValue, {{X, Y}, {Date, Time}, Type});

getOneValue(Name, {Date, Time}, Type)
  -> call(getOneValue, {Name, {Date, Time}, Type}).

getStationMean({X, Y}, Type)
  -> call(getStationMean, {{X, Y}, Type});

getStationMean(Name, Type)
  -> call(getStationMean, {Name, Type}).

getDailyMean(Type, Date)
  -> call(getDailyMean, {Type, Date}).

getPredictedIndex({X, Y}, {Date, Time}, Type)
  -> call(getPredictedIndex, {{X, Y}, {Date, Time}, Type}).