%%%-------------------------------------------------------------------
%%% @author piotr
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. mar 2018 11:36
%%%-------------------------------------------------------------------
-module(power).
-author("piotr").

%% API
-export([power/2]).


power(X, 0) ->
  1;
power(X, 1) ->
  X;
power(X, Y) ->
  X * power(X, Y-1).