-module(metronome).
-export([start/0]).

start()->
    io:format("starting metronome"),
    Ret = application:start(?MODULE),
    io:format(" ~p.\n", [Ret]).
