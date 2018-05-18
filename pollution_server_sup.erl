%%%-------------------------------------------------------------------
%%% @author piotr
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. maj 2018 13:21
%%%-------------------------------------------------------------------
-module(pollution_server_sup).
-author("piotr").

%% API
-export([sup/0, restart/0]).

restart() ->
  receive
    {'EXIT', Pid, normal} -> ok;
    {'EXIT', Pid, Reason} -> sup()
  end.

sup() ->
  process_flag(trap_exit, true),
  Pid = spawn_link(pollution_server, init, []),
  register(pollServer, Pid),
  restart().



