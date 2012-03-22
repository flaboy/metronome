-module(metronome_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, gc/0]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    true = metronome_db:init(),
    timer:apply_interval(3600*1000, ?MODULE, gc, []),
    metronome_sup:start_link().

stop(_State) ->
    ok.
    
gc()-> metronome_db:gc(metronome_timer:now()).