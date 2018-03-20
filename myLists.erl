%%%-------------------------------------------------------------------
%%% @author piotr
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. mar 2018 13:49
%%%-------------------------------------------------------------------
-module(myLists).
-author("piotr").

%% API
-export([contains/2]).
-export([duplicateElements/1]).
-export([sumFloats/1]).
-export([sumFloatsTail/1]).

contains([], _) ->
  false;
contains([Val | T], Val) ->
  true;
contains([H | T], Val) ->
  contains(T, Val).

duplicateElements([]) ->
  [];
duplicateElements([H | T]) ->
  [H, H | duplicateElements(T)].

sumFloats([]) ->
  0.0;
sumFloats([H | T]) when is_float(H) ->
  H + sumFloats(T);
sumFloats([H | T]) ->
  sumFloats(T).

sumFloatsTailWithAcc([], Acc) ->
  Acc;
sumFloatsTailWithAcc([H | T], Acc) when is_float(H) ->
sumFloatsTailWithAcc(T, H + Acc);
sumFloatsTailWithAcc([H | T], Acc) ->
  sumFloatsTailWithAcc(T, Acc).

sumFloatsTail([]) ->
  0.0;
sumFloatsTail([H | T]) ->
  sumFloatsTailWithAcc ([H | T], 0.0).


