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

onpStack([Elem | T], [X | Z]) when Elem == "sqrt" ->
  onpStack(T, [math:sqrt(X) | Z]);

onpStack([Elem | T], [X, Y | Z]) when Elem == "pow" ->
  onpStack(T, [math:pow(Y, X) | Z]);

onpStack([Elem | T], [X | Z]) when Elem == "sin" ->
  onpStack(T, [math:sin(X) | Z]);

onpStack([Elem | T], [X | Z]) when Elem == "cos" ->
  onpStack(T, [math:cos(X) | Z]);

onpStack([Elem | T], [X | Z]) when Elem == "tan" ->
  onpStack(T, [math:tan(X) | Z]);


onpStack([Elem | T], Stack) ->
    case lists:member($., Elem)  of
      true -> onpStack(T, [list_to_float(Elem) | Stack]);
      false -> onpStack(T, [list_to_integer(Elem) | Stack])
    end;

onpStack([], Stack) ->
  hd(Stack).

onp(String) ->
  onpStack(string:tokens(String, " "), []).

