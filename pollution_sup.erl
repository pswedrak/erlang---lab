%%%-------------------------------------------------------------------
%%% @author piotr
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. maj 2018 22:04
%%%-------------------------------------------------------------------
-module(pollution_sup).
-behaviour(supervisor).
-author("piotr").

%% API
-export([start_link/0, init/1]).


start_link() -> supervisor:start_link({local, pollution_sup}, pollution_sup, []).

init(_) ->
  {ok, {
    {one_for_one, 2, 3},
    [ {pollution_gen_server,
      {pollution_gen_server, start, []},
      permanent, brutal_kill, worker, [var_server]}
    ]}
  }.

