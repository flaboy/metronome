-module(metronome).
-export([start/0, clear/0, stop/0]).
-export([update/3, lookup/1]).

start()->
    io:format("starting metronome"),
    Ret = application:start(?MODULE),
    io:format(" ~p.\n", [Ret]).
    
stop()-> application:stop(?MODULE).
clear()-> metronome_db:clear().

update(Key, Incr, TTL)->
    metronome_db:update(Key, Incr, TTL, metronome_timer:now()).
lookup(Key)->
    metronome_db:lookup(Key, metronome_timer:now()).