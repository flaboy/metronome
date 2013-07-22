-module(metronome_timer).
-export([start_link/0, init/0, now/0, now/1]).

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
    ets:insert(metronome, {now_str, time_now_str()}),
    timer:sleep(1000),
    loop().
    
now()->
    case ets:lookup(metronome, now) of
        [{now,N}] -> N;
        _ -> 0
    end.

now(str)->
    case ets:lookup(metronome, now_str) of
        [{now,N}] -> N;
        _ -> time_now_str()
    end.

time_now_str()->
    {{Y,M, D}, {H,I,S}} = calendar:local_time(),
    io_lib:format("~4.10.0B-~2.10.0B-~2.10.0B::~2.10.0B:~2.10.0B:~2.10.0B", 
        [Y, M, D, H, I, S]).

week(1)-> <<"Mon">>;
week(2)-> <<"Tur">>;
week(3)-> <<"Wed">>;
week(4)-> <<"Thu">>;
week(5)-> <<"Fri">>;
week(6)-> <<"Sat">>;
week(7)-> <<"Sun">>;
week(0)-> <<"Sun">>.
