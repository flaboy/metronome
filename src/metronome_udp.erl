-module(metronome_udp).
-export([start_link/0,init/0]).

start_link()->
    Pid = spawn_link(?MODULE,init,[]),
    {ok,Pid}.
    
init()->
    {ok, {Ip, Port}} = application:get_env(udp_server),
    {ok, Sock} = gen_udp:open(Port, [{ip,Ip},list,{active,true},{reuseaddr,true}]),
    metronome_server:loop(Sock).
