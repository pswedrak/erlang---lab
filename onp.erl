%%%-------------------------------------------------------------------
%%% @author piotr
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. mar 2018 12:10
%%%-------------------------------------------------------------------
%%% 1 + 2*3 - 4/5 + 6          --> 1 2 3 * 4 5 / - 6 + +
%%% 1 + 2 + 3 + 4 + 5 + 6*7    --> 1 2 + 3 + 4 + 5 + 6 7 * +
%%% ( (4 + 7) / 3 ) * (2 - 19) --> 4 7 + 3 / 2 19 - *
%%% 17 * (31 + 4) / ( (26 - 15) * 2 - 22 ) - 1
%%%                            --> 17 31 4 + 26 15 - 2 * 22 - / 1 - *
-module(onp).
-author("piotr").

%% API
-export([onp/1]).

onpStack([Elem | T], [X, Y | Z]) when Elem == "+" ->
  onpStack(T, [Y + X | Z]);

onpStack([Elem | T], [X, Y | Z]) when Elem == "-" ->
  onpStack(T, [Y - X | Z]);

onpStack([Elem | T], [X, Y | Z]) when Elem == "*" ->
  onpStack(T, [Y * X | Z]);

onpStack([Elem | T], [X, Y | Z]) when Elem == "/" ->
  onpStack(T, [Y / X | Z]);

onpStack([Elem | T], Stack) ->
  onpStack(T, [list_to_integer(Elem) | Stack]);

onpStack([], Stack) ->
  hd(Stack).

onp(List) ->
  onpStack(string:tokens(List, " "), []).

