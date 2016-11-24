-module(txtSort).

-export([main/1]).
-export([removeDubs/1]).
-export([sort/1]).
-export([runSort/1]).
-export([wordCount/3]).

main(FileName) ->
    io:format("~nReading: ~p~n", [FileName]),
    {ok, File} = file:read_file(FileName),
    Content = unicode:characters_to_list(File),
    TokenList = string:tokens(string:to_lower(Content), " .,;:!?~/>'<{}£$%^&()@-=+_[]*#\\\n\r\"0123456789"),
    runSort(TokenList).

runSort(TokenList) ->
    SortedList=sort(TokenList),
	RemoveDubs=removeDubs(SortedList),
    {ok, F} = file:open("wordsList.txt", [write]), % writes to a file
    register(my_output_file, F),
    Counted = wordCounter(RemoveDubs,TokenList,0),
    io:format("~nTotal unique words: ~p~n", [Counted]).
	
sort([Pivot|T]) ->
    sort([ X || X <- T, X < Pivot]) ++
    [Pivot] ++
    sort([ X || X <- T, X >= Pivot]);
	sort([]) -> [].

removeDubs([Pivot|T])->
	[Pivot| [X || X <- removeDubs(T), X /= Pivot]];
	removeDubs([]) -> [].

wordCounter([H|T],TokenList,N) ->
    %io:fwrite("~p \t:  ~p~n", [H,T]),
    wordCount(H, TokenList, 0),
    wordCounter(T,TokenList,N+1);

wordCounter([], _, N) -> N.

wordCount(Word,[H|T],N) ->
    case Word == H of 
        true -> wordCount(Word, T, N+1);
        false -> wordCount(Word, T, N)
    end;
    
wordCount(Word,[],N) -> 
    io:fwrite("~p   \t\t:  ~p ~n", [N,Word]),
    io:format(whereis(my_output_file), "~p   \t: ~p ~n", [N,Word]).