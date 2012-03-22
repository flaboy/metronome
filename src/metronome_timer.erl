-module(metronome_timer).
-export([start_link/0, init/0, now/0]).

start_link()->
    Pid = spawn_link(?MODULE, init,[]),
    {ok, Pid}.

init()->
    ets:new(metronome, [set,protected,named_table]),
    loop().

loop()->
    {M,S,_} = erlang:now(),
    N = M*1000*1000 + S,
    ets:insert(metronome, {now, N}),
    timer:sleep(1000),
    loop().
    
now()->
    case ets:lookup(metronome, now) of
        [{now,N}] -> N;
        _ -> 0
    end.
