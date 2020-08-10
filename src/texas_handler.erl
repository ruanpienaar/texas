-module(texas_handler).

-callback handle(cowboy:req(), term()) -> term().

-include_lib("kernel/include/logger.hrl").

-behaviour(cowboy_handler).

-export([
    init/2
]).

init(Req, Opts=[M]) ->
    R = M:handle(Req, Opts),
    ResponseCode = maps:get(response_code, R, 200),
    ResponseHeaders = maps:get(response_headers, R, #{<<"content-type">> => <<"text/plain">>}),
    ResponseBody = maps:get(response_body, R, <<"">>),
    {ok, cowboy_req:reply(ResponseCode, ResponseHeaders, ResponseBody, Req), Opts}.
