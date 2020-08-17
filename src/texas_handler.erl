-module(texas_handler).

-callback handle(cowboy:req(), term()) -> term().

-include_lib("kernel/include/logger.hrl").

-behaviour(cowboy_handler).

-export([
    init/2,
    file_serve/2
]).

init(Req, Opts=[M]) ->
    R = M:handle(Req, Opts),
    ResponseCode = maps:get(
        response_code,
        R,
        200
    ),
    ResponseHeaders = maps:get(
        response_headers,
        R,
        #{<<"content-type">> => <<"text/plain">>}
    ),
    ResponseBody = maps:get(
        response_body,
        R,
        <<"">>
    ),
    {
        ok,
        cowboy_req:reply(ResponseCode, ResponseHeaders, ResponseBody, Req),
        Opts
    }.

%% @doc
%% To be used by texas_handler modules for serving the contents of a folder
%% NB! relies on the cmd `file` to be present in the underlying OS.
%% Assumes that application AppName will have a priv/www directory.
%% @end
file_serve(Path, AppName) ->
    SubstitutePath =
        case Path of
            <<"/">> ->
                <<"/index.html">>;
            _ ->
                Path
        end,
    Filename = code:priv_dir(AppName) ++ "/www" ++ binary_to_list(SubstitutePath),
    case file:read_file(Filename) of
        {ok, Binary} ->
            #{
                response_code => 200,
                response_body => Binary,
                response_headers => #{ <<"content-type">> => content_type(Filename) }
            };
        {error, Reason} ->
            #{
                response_code => 404,
                response_body => jsx:encode(#{
                    error => any:to_binary(Reason),
                    uri => Path
                }),
                response_headers => #{ <<"content-type">> => <<"text/plain">> }
            }
    end.

%% ----------------------------------------------------------------------------

content_type(Filename) ->
    case os:cmd("file -N -r --mime-type " ++ Filename ++ " | awk '{ print $2}'") of
        "cannot" ->
            <<"text/plain">>;
        MimeType ->
            list_to_binary(MimeType -- "\n")
    end.
