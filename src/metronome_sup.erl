
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
    P1 = [?CHILD(metronome_timer, worker)],
    P2 = case application:get_env(metronome, udp_server) of
            {ok, {_,_}} -> [?CHILD(metronome_udp, worker) | P1];
            _ -> P1
        end,
    P3 = case application:get_env(metronome, tcp_server) of
            {ok, {_,_}} -> 
                    TcpServer = {metronome_server, {metronome_listener , start_link, 
                    [metronome_server,[list, {packet,line},{active, true}, {reuseaddr, true}]]},
                    permanent, 5000, worker, [metronome_listener ,metronome_server]},
                    [TcpServer | P2];
            _ -> P2
        end,
    {ok, { {one_for_one, 5, 10}, P3} }.

