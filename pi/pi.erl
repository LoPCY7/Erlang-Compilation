-module(pi).
-export([pi/0]).


pi() -> io_lib:format("~.5f",[4 * pi(0,1,1)]). %formats to 5 decimal places

pi(T,M,D) -> 
PiEquation = 1 / D,
    if 
        PiEquation > 0.0000001-> pi(T+(M*PiEquation), M*-1, D+2); %checks the decimal places
        true -> T        
    end. 