%%%-------------------------------------------------------------------
%%% @author piotr
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. kwi 2018 12:51
%%%-------------------------------------------------------------------
-module(pollutionTest).
-author("piotr").

-include_lib("eunit/include/eunit.hrl").

createMonitor_test() ->
  ?assert(pollution:createMonitor() =:= #{}).

addStation_test() ->
  [?assert(pollution:addStation("Aleja", {50.2, 40.2}, #{}) =:= #{{station, "Aleja", {coordinates, 50.2, 40.2}} => []})].

