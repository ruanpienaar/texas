-module(texas_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-include("texas.hrl").

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    M = application:get_env(texas, handler_module, texas_example),
    Dispatch = cowboy_router:compile([{'_', routes(M)}]),
    {ok, _} = cowboy:start_clear(
        http,
        [{port, 8080}],
        #{ env => #{dispatch => Dispatch} }
    ),
    {ok, _} = texas_sup:start_link().

stop(_State) ->
    ok.

routes(M) ->
    [
        {"/[...]", texas_handler, [M]}
    ].
