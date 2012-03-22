-module(metronome_server).
-export([start_link/1, update/1, init/1, loop/1]).

start_link(Sock)->
    Pid = spawn_link(?MODULE, init, [Sock]),
    {ok, Pid}.

init(Sock)-> loop(Sock).

loop(Sock)->
    receive
        {tcp, Sock, Line}->
            Packet = update(Line),
            gen_tcp:send(Sock, Packet),
            loop(Sock);
            
        {tcp_closed,Sock} -> exit(normal);
        
        {udp, Sock, FromAddr, FromPort, Line}->
            Packet = update(Line),
            gen_udp:send(Sock, FromAddr, FromPort, Packet),
            loop(Sock);
            
        Msg ->
            erlang:display(Msg),
            loop(Sock)
    end.

update(L)->
    try
        Line = string:strip(L,right,$\n),
        {Key, TTL, Id} = case string:chr(Line, $ ) of
                0 -> {Line, 1, ""};
                N -> 
                    KeyStr = string:substr(Line, 1, N-1),
                    TailStr = string:substr(Line, N+1),
                    case string:chr(TailStr, $ ) of
                        0 -> {KeyStr, be_int(TailStr), ""};
                        M -> 
                            {KeyStr, be_int(string:substr(TailStr, 1, M-1)), string:substr(TailStr, M+1)}
                    end
                end,
        Value = metronome_db:update(Key, 1, TTL, metronome_timer:now()),
        [integer_to_list(Value), $ , Id, $\n]
    catch _:Err->
        erlang:display({?LINE, Err}), "1\n"
    end.
    
be_int(Ttl)->try list_to_integer(Ttl) catch _:_ -> 1 end.
