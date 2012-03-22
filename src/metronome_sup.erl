
-module(metronome_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    Timer = ?CHILD(metronome_timer, worker),
    UdpServer = ?CHILD(metronome_udp, worker),
    TcpServer = {metronome_server, {metronome_listener , start_link, 
            [metronome_server,[list, {packet,line},{active, true}, {reuseaddr, true}]]},
            permanent, 5000, worker, [metronome_listener
 ,metronome_server]},
    {ok, { {one_for_one, 5, 10}, [Timer,TcpServer,UdpServer]} }.

