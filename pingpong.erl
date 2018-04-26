%%%-------------------------------------------------------------------
%%% @author piotr
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. kwi 2018 17:42
%%%-------------------------------------------------------------------
-module(pingpong).
-author("piotr").

%% API
-export([start/0]).
-export([stop/0]).
-export([play/1]).

start() ->  register(ping, spawn(fun() -> loopPing() end)),
            register(pong, spawn(fun() -> loopPong() end)).

play(N) -> ping ! N.

loopPing() ->
  receive
    0 ->  ok;
    N ->  io:format("PING! ~w~n", [N]),
      pong ! N,
      timer:sleep(100),
      loopPing()
    after
      20000 -> ok
  end.

loopPong() ->
  receive
    0 -> ok;
    N ->  io:format("PONG! ~w~n", [N]),
      ping ! (N-1),
      timer:sleep(100),
      loopPong()
  after
    20000 -> ok
  end.

stop() -> ping ! 0,
          pong ! 0.

