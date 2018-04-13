%%%-------------------------------------------------------------------
%%% @author piotr
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. mar 2018 13:13
%%%-------------------------------------------------------------------
-module(qsort).
-author("piotr").

%% API
-export([qs/1]).
-export([randomElems/3]).
-export([compareSpeeds/3]).

lessThan(List, Arg) -> lists:filter(fun (X) -> X < Arg end, List).

grtEqThan(List, Arg) -> lists:filter(fun (X) -> X >= Arg end, List).

qs([Pivot | Tail]) -> qs (lessThan(Tail, Pivot)) ++ [Pivot] ++ qs(grtEqThan(Tail, Pivot));
qs([]) -> [].

randomElems(N, Min, Max) -> [round(rand:uniform() * (Max - Min) + Min) || X <- lists:seq(1,N)].

compareSpeeds(List, {qsort, qs}, {lists, sort}) ->
    {(timer:tc(qsort, qs, [List])), (timer:tc(lists, sort, [List]))}.



