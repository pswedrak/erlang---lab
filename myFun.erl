%%%-------------------------------------------------------------------
%%% @author piotr
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. mar 2018 15:33
%%%-------------------------------------------------------------------
-module(myFun).
-author("piotr").

%% API
-export([myMap/2]).
-export([myFilter/2]).
-export([digitSum/1]).
-export([div3/0]).

myMap(Fun, List) -> [Fun(X) || X <- List].
myFilter(Cond, List) -> [X || X <- List, Cond(X)].

digitSum(Number) -> lists:foldl(fun (X, Y) -> (X - 48) + Y end, 0, integer_to_list(Number)).

div3() -> lists:filter(fun (X) -> (X rem 3) == 0 end, qsort:randomElems(1000000,0,1000000)).