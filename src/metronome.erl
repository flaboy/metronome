-module(metronome).
-export([start/0, clear/0, stop/0]).

start()->
    io:format("starting metronome"),
    Ret = application:start(?MODULE),
    io:format(" ~p.\n", [Ret]).
    
stop()-> application:stop(?MODULE).
clear()-> metronome_db:clear().