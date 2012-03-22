-module(metronome_db).
-export([init/0,
        update/4,
        gc/1]).

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
    ok = erlang:load_nif(priv_dir(metronome)++"/metronome_drv", 0), true.

update(Key, Incr, Ttl, TimestampNow)-> {error, nif_not_loaded}.
gc(TimestampNow) -> ok.
