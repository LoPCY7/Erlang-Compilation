-module(ccConcurrent).
-export([load/1]).
-export([count/3]).
-export([storage/2]).

load(F)->
io:format("~nReading: ~p~n", [F]),
   {ok, Bin} = file:read_file(F),
   List=binary_to_list(Bin),
   Length=round(length(List)/20),
   Ls=string:to_lower(List),
   SplittedParts=split(Ls,Length),
   io:fwrite("The file has been splitted to 20 parts~n"),
   StoredID = spawn(?MODULE, storage, [[],1]),
   io:format("~n Spawned : Storage ~n Pid : ~p~n",[StoredID]),
   main(SplittedParts,1,StoredID).

% Joins
join([],[])->[];
join([],R)->R;
join([H1 |T1],[H2|T2])->
   {_C,N}=H1,
   {C1,N1}=H2,
   [{C1,N+N1}]++join(T1,T2).

% Main
main([H|T],N,Cid) ->
  goSpawner(H,N,Cid),
 %Debugging % io:fwrite("~nStarting Process # ~p \t using SPart :~p ~n",[N,H]),
  main(T,N+1,Cid);
% Main Stop Function
main([], N,_) -> io:fwrite(" Spawned : ~p Processes~n",[N-1]).

receiveMessage(SPart, Pid,N,Alph) ->
  receive
    {start, Pid, CountedList,N} -> run_receiveMessage(SPart, Pid, CountedList,N,Alph);
    Msg ->
      io:format("~p received unexpected message ~p~n", [SPart, Msg]),
      receiveMessage(SPart, Pid,N,Alph)
  end.

% Run
run_receiveMessage(SPart, Pid, CountedList, N,[H|T])  ->
    Num=count(H,SPart,0),
    CountedList2=CountedList++[{[H],Num}],
    run_receiveMessage(SPart, Pid, CountedList2,N,T);

run_receiveMessage(_, Pid, CountedList,N,[]) ->
  % Debugging    %io:fwrite("Completed Process # ~p~n",[N]),
  % Debugging   %io:fwrite("Counted List = ~n~p~n",[CountedList]),
  Pid ! {start, N, CountedList}.

% from go to spawn
goSpawner(WordList,N,Cid) ->
  SeenList = [],
  Alph=[$a,$b,$c,$d,$e,$f,$g,$h,$i,$j,$k,$l,$m,$n,$o,$p,$q,$r,$s,$t,$u,$v,$w,$x,$y,$z],
  Processes = [spawn_link(fun() -> 
          receiveMessage(WordList, Cid,N,Alph) end) ],
  [ Process ! {start, Cid, SeenList,N} || Process <- Processes].
  
% Splits to SplittedParts
split([],_)->[];

split(List,Length)->
   S1=string:substr(List,1,Length),
   case length(List) > Length of
      true->S2=string:substr(List,Length+1,length(List));
      false->S2=[]
   end,
   [S1]++split(S2,Length).

%  Counts the characters in the list
count(_, [],N)->N;
count(Ch, [H|T],N) ->
   case Ch==H of
   true-> count(Ch,T,N+1);
   false -> count(Ch,T,N)
end.

storage(ResultsList,Joins) ->
  receive
    {start, _, CountedList} -> 
    case ResultsList == []  of
      true ->  Shuffle = CountedList;
      false -> Shuffle = join(CountedList, ResultsList)
    end,
    case Joins == 20 of
      true -> io:fwrite("~n Storage ~p ~nResults = ~p Processes processed~n",[Shuffle,Joins]),
      storage(Shuffle,Joins);
      false -> storage(Shuffle,Joins+1)
    end;
    Msg ->
      io:format("~p Storage received unexpected message ~n", [Msg]),
      storage(ResultsList,Joins)
  end.