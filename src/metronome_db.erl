-module(metronome_db).
-export([init/0,
        update/4,
        gc/1,
        lookup/2,
        clear/0,
        is_loaded/0]).

priv_dir(App)->
    case code:priv_dir(App) of
        {error,bad_name} ->
            AppStr = atom_to_list(App),
            Path = code:where_is_file(AppStr++".app"),
            N = string:len(Path) - string:len(AppStr) - 5,
            string:substr(Path, 1, N) ++ "/../priv";
        Path when is_list(Path) -> Path
    end.

init() ->
    case metronome_db:is_loaded() of
        false -> erlang:load_nif(priv_dir(metronome)++"/metronome_drv", 0), true;
        true -> true
    end.

update(_key, _incr, _ttl, _timestamp_now)-> {error, nif_not_loaded}.
lookup(_key, _timestamp_now)-> {error, nif_not_loaded}.
gc(_timestamp_now) -> ok.
is_loaded() -> false.
clear() -> ok.