-module(sort).
-export([main/1]).
-export([sort/1]).
-export([removeDubs/1]).
-export([count/1]).
-export([count/2]).

main(NumList)->
	SortedList=sort(NumList),
	RemoveDubs=removeDubs(SortedList),
	CountList=count(RemoveDubs),
	io:format("~nTotal Unique items: ~p~n", [CountList]).

sort([Pivot|T]) ->
    sort([ X || X <- T, X < Pivot]) ++
    [Pivot] ++
    sort([ X || X <- T, X >= Pivot]);
sort([]) -> [].

removeDubs([Pivot|T])->
[Pivot| [X || X <- removeDubs(T), X /= Pivot]];
removeDubs([]) -> [].

count(L) ->
    count(L,0).

count([],N)-> N;

count([H|T],N) ->                           %counts items in list using tail recursion
    io:fwrite("~p", [H]), 
    io:fwrite("  "), 
    count(T, N+1).